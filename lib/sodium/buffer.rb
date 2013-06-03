require 'sodium'
require 'securerandom'

class Sodium::Buffer
  def self.key(size)
    self.new SecureRandom.random_bytes(size)
  end

  def self.nonce(size)
    self.new SecureRandom.random_bytes(size)
  end

  def self.empty(size)
    self.new("\0" * size).tap {|buffer| yield buffer if block_given? }
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
  end

  def pad(size)
    self.class.new(
      ("\0" * size) + @bytes
    )
  end

  def unpad(size)
    self.class.new(
      @bytes.respond_to?(:byteslice) ?
        @bytes.byteslice(size .. -1) :
        @bytes.unpack("@#{size}a*").first # 1.8
    )
  end

  def bytesize
    @bytes.bytesize
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
