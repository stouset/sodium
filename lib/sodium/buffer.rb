require 'sodium'
require 'securerandom'

class Sodium::Buffer
  def self.key(size)
    Sodium::Random.bytes(size)
  end

  def self.nonce(size)
    Sodium::Random.bytes(size)
  end

  def self.empty(size)
    self.new("\0" * size).tap {|buffer| yield buffer if block_given? }
  end

  def self.ljust(string, size)
    size = (size > string.bytesize) ? size : string.bytesize

    self.empty(size) do |buffer|
      buffer[0, string.bytesize] = string
    end
  end

  def self.rjust(string, size)
    size = (size > string.bytesize) ? size : string.bytesize

    self.empty(size) do |buffer|
      buffer[size - string.bytesize, string.bytesize] = string
    end
  end

  def self.lpad(string, size, &block)
    self.rjust(string, string.bytesize + size, &block)
  end

  def self.rpad(string, size, &block)
    self.ljust(string, string.bytesize + size, &block)
  end

  def self.new(bytes, size = bytes.bytesize)
    raise Sodium::LengthError, "buffer must be exactly #{size} bytes long" unless
      bytes.bytesize == size

    bytes.kind_of?(self) ?
      bytes              :
      super(bytes)
  end

  def initialize(bytes)
    # unwrap ZeroingDelegator if present
    bytes = bytes.to_str

    # allocate enough memory on the heap to store the bytes
    pointer = Sodium::FFI::LibC.calloc(1, bytes.bytesize)

    # use the ZeroingDelegator helper methods to prevent the pointer
    # from being swapped to disk, to wipe its memory on garbage
    # collection, and to attach our own finalizer to free() the memory
    # on garbage collection as well
    ZeroingDelegator._mlock!          pointer, bytes.bytesize
    ZeroingDelegator._finalize! self, pointer, bytes.bytesize,
      &self.class._finalizer(pointer, bytes.bytesize)

    # now that the pointer can't be swapped out to disk, it is safe to
    # write memory contents to it
    pointer.write_string(bytes)

    # zero out the bytes passed to us, since we can't control their
    # lifecycle
    ZeroingDelegator._mwipe!(bytes, bytes.bytesize)

    # WARNING: The following section is critical. Edit with caution!
    #
    # We create a new pointer to the bytes allocated earlier and set a
    # hidden instance variable pointing at ourself. We do the latter
    # so that there is a cyclic dependency between the buffer and the
    # pointer; if either is still live in the current scope, it is
    # enough to prevent the other from being collected. We create the
    # new pointer since the existing pointer is referenced by the
    # finalizer; if we didn't, its reference in the finalizer proc
    # would keep us from being garbage collected because it holds a
    # pointer to us.
    @bytesize = bytes.bytesize
    @bytes    = FFI::Pointer.new(pointer.address)
    @bytes.instance_variable_set(:@_sodium_buffer, self)

    @bytes.freeze
    self  .freeze
  end

  def ==(bytes)
    self.to_s == Sodium::Buffer.new(bytes)
  end

  def +(bytes)
    Sodium::Buffer.empty(self.bytesize + bytes.bytesize) do |buffer|
      buffer[0,             self .bytesize] = self
      buffer[self.bytesize, bytes.bytesize] = bytes
    end
  end

  def ^(bytes)
    bytes = Sodium::Buffer.new(bytes)

    raise ArgumentError, %{must only XOR strings of equal length} unless
      self.bytesize == bytes.bytesize

    Sodium::Buffer.empty(self.bytesize) do |buffer|
      Sodium::FFI::Memory.sodium_memxor(
        buffer.to_ptr,
        self  .to_ptr,
        bytes .to_ptr,
        bytes .bytesize
      )
    end
  end

  def []=(offset, size, bytes)
    raise ArgumentError, %{must only assign to existing bytes in the buffer} unless
      self.bytesize >= offset + size

    raise ArgumentError, %{must reassign only a fixed number of bytes} unless
      size == bytes.bytesize

    # ensure the original bytes get cleared
    bytes = Sodium::Buffer.new(bytes)

    Sodium::FFI::Memory.sodium_memput(
      self .to_ptr,
      bytes.to_ptr,
      offset,
      size
    )

    true
  end

  def [](offset, size)
    self.class.new(
      @bytes.get_bytes(offset, size)
    )
  end

  alias byteslice []

  def bytesize
    @bytesize
  end

  def rdrop(size)
    self[0, self.bytesize - size]
  end

  def ldrop(size)
    self[size, self.bytesize - size]
  end

  def inspect
    # this appears to be equivalent to the default Object#inspect,
    # albeit without instance variables
    "#<%s:0x%x>" % [ self.class.name, self.__id__ * 2 ]
  end

  def to_s
    # Pretend to return a string, but really return a Delegator that
    # wipes the string's memory when it gets garbage collected.
    #
    # Since any calls to the methods of the String inside the
    # delegator by necessity have the delegator's `method_missing` in
    # their backtrace, there can never be a situation where there is a
    # live pointer to the string itself but not one to the delegator.
    ZeroingDelegator.new(
      @bytes.read_bytes(@bytesize)
    )
  end

  def to_ptr
    @bytes
  end

  private

  def self._finalizer(pointer, size)
    proc { self._free!(pointer) }
  end

  def self._free!(pointer)
    Sodium::FFI::LibC.free(pointer)
  end
end

class Sodium::Buffer::ZeroingDelegator
  self.instance_methods.map(&:to_sym).each do |method|
   undef_method method unless [
      :__id__,
      :__send__,
      :object_id,
      :equal?,
      :freeze,
      :frozen?,
    ].include?(method)
  end

  def initialize(string, &finalizer)
    # specify class name explicitly, since we're letting the `class`
    # method delegate to the wrapped object
    Sodium::Buffer::ZeroingDelegator._mlock!          string, string.bytesize
    Sodium::Buffer::ZeroingDelegator._finalize! self, string, string.bytesize,
      &finalizer

    self.__setobj__(string)
    self.__getobj__.freeze
    self           .freeze
  end

  def ==(other)
    return false unless
      self.bytesize == other.bytesize

    Sodium::FFI::Crypto.sodium_memcmp(
      self.__getobj__,
      other,
      other.bytesize
    ) == 0
  end

  def to_s
    self
  end

  def to_str
    # Okay, fine, you win. I'll give you access to the raw string
    # we're wrapping. But now I can't wipe the data when you're done
    # with it.
    self.__getobj__.
      tr('', ''). # trick to force the string to be copied
      freeze
  end

  alias dup   to_s
  alias clone to_s

  protected

  def method_missing(*args, &block)
    self.__getobj__.__send__(*args, &block)
  ensure
    $@.delete_if do |trace|
      # delete lines from the backtrace that originate from the
      # __send__ line above
      trace =~ %r{ \A #{Regexp.quote(__FILE__)}:#{__LINE__ - 5} : }x
    end if $@
  end

  def __getobj__
    @_obj
  end

  def __setobj__(string)
    @_obj = string
  end

  private

  def self._finalizer(pointer, size, &finalizer)
    proc {
      self._mwipe!   pointer, size
      finalizer.call pointer, size if finalizer
    }
  end

  def self._finalize!(delegator, pointer, size, &finalizer)
    ObjectSpace.define_finalizer delegator,
      self._finalizer(pointer, size, &finalizer)
  end

  def self._mwipe!(pointer, size)
    Sodium::FFI::Crypto.sodium_memzero(pointer, size)
  end

  def self._mlock!(pointer, size)
    Sodium::FFI::LibC.mlock(pointer, size) or
      raise Sodium::MemoryError, 'could not mlock(2) secure buffer into memory'
  end
end
