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
    # initialize with a forced hard copy of the bytes (Ruby is smart
    # about using copy-on-write for strings 24 bytes or longer, so we
    # have to perform a no-op that forces Ruby to copy the bytes)
    @bytes = bytes.tr('','').tap {|s|
      s.force_encoding('BINARY') if
      s.respond_to?(:force_encoding)
    }.freeze

    self.class._mlock! @bytes
    self.class._mwipe!  bytes

    ObjectSpace.define_finalizer self,
      self.class._finalizer(@bytes)

    self.freeze
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
        buffer.to_str,
        self.to_str,
        bytes.to_str,
        bytes.bytesize
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
      self.to_str,
      bytes.to_str,
      offset,
      size
    )

    true
  end

  def [](*args)
    return self.class.new(
      @bytes.byteslice(*args).to_s
    ) if (
      # Ruby 1.8 doesn't have byteslice
      @bytes.respond_to?(:byteslice) or

      # JRuby reuses memory regions when calling byteslice, which
      # results in them getting cleared when the new buffer initializes
      defined?(RUBY_ENGINE) and RUBY_ENGINE == 'java'
    )

    raise ArgumentError, 'wrong number of arguments (0 for 1..2)' if
      args.length < 1 or args.length > 2

    start, finish = case
      when args[1]
        # matches: byteslice(start, size)
        start  = args[0].to_i
        size   = args[1].to_i

        # if size is less than 1, finish needs to be small enough that
        # `finish - start + 1 <= 0` even after finish is wrapped
        # around to account for negative indices
        finish = size > 0  ?
          start + size - 1 :
          - self.bytesize.succ

        [ start, finish ]
      when args[0].kind_of?(Range)
        # matches: byteslice(start .. finish)
        # matches: byteslice(start ... finish)
        range  = args[0]
        start  = range.begin.to_i
        finish = range.exclude_end? ? range.end.to_i - 1 : range.end.to_i

        [ start, finish ]
      else
        # matches: byteslice(start)
        [ args[0].to_i, args[0].to_i ]
    end

    # ensure negative values are wrapped around explicitly
    start  += self.bytesize if start  < 0
    finish += self.bytesize if finish < 0
    size    = finish - start + 1

    # this approach ensures the bytes are copied into new memory, so
    # instantiating a new buffer doesn't clear the bytes in the
    # existing buffer
    bytes = (start >= 0 and size >= 0)         ?
      @bytes.unpack("@#{start}a#{size}").first :
      ''

    self.class.new(bytes)
  end

  alias byteslice []

  def bytesize
    @bytes.bytesize
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

  def to_str
    @bytes.to_str
  end

  private

  def self._finalizer(buffer)
    proc { self._mwipe!(buffer) }
  end

  def self._mwipe!(buffer)
    Sodium::FFI::Crypto.sodium_memzero(buffer, buffer.bytesize)
  end

  def self._mlock!(buffer)
    Sodium::FFI::LibC.mlock(buffer, buffer.bytesize) or
      raise Sodium::MemoryError, 'could not mlock(2) secure buffer into memory'
  end
end
