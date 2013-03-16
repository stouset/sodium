require 'sodium'
require 'ffi'

module Sodium::NaCl
  def self.nacl_default(klass, primitive)
    klass.const_set(:DEFAULT, primitive)
  end

  def self.nacl_family(scope, subclass, implementation)
    klass     = _define_subclass(scope, subclass)
    family    = _extract_family_name(scope)
    primitive = subclass.to_s.downcase.to_sym

    methods   = {}
    constants = {
      :implementation => implementation,
      :primitive      => primitive
    }

    yield constants, methods

    _install_implementation scope, klass, primitive
    _install_constants      klass, family, primitive, implementation, constants
    _install_methods        klass, family, primitive, implementation, methods
  end

  def self._define_subclass(scope, name)
    scope.const_set name, Class.new(scope)
  end

  def self._extract_family_name(klass)
    'crypto_' + klass.name.split('::').last.downcase
  end

  def self._install_implementation(scope, klass, primitive)
    scope.implementations[primitive] = klass
  end

  def self._install_constants(klass, family, primitive, implementation, constants)
    constants.each do |name, value|
      family = family.to_s.upcase
      name   = name.to_s.upcase

      self. const_set("#{family}_#{primitive}_#{name}", value)
      klass.const_set(name,                             value)
    end
  end

  def self._install_methods(klass, family, primitive, implementation, methods)
    methods.each do |name, arguments|
      nacl = self
      imp  = [ family, primitive, implementation, name ].compact.join('_')
      meth = [ 'nacl',                            name ].compact.join('_')

      self.attach_function imp, arguments[0..-2], arguments.last

      (class << klass; self; end).send(:define_method, meth) do |*a, &b|
        nacl.send(imp, *a, &b) == 0
      end
    end
  end
end

module Sodium::NaCl
  extend FFI::Library

  ffi_lib 'sodium'

  nacl_family Sodium::Auth, :HMACSHA256, :ref do |constants, methods|
    constants.update(
      :version  => '-',
      :bytes    => 32,
      :keybytes => 32
    )

    methods.update(
      nil     => [ :pointer, :pointer, :ulong_long, :pointer, :int ],
      :verify => [ :pointer, :pointer, :ulong_long, :pointer, :int ]
    )
  end

  nacl_family Sodium::Auth, :HMACSHA512256, :ref do |constants, methods|
    constants.update(
      :version  => '-',
      :bytes    => 32,
      :keybytes => 32
    )

    methods.update(
      nil     => [ :pointer, :pointer, :ulong_long, :pointer, :int ],
      :verify => [ :pointer, :pointer, :ulong_long, :pointer, :int ]
    )
  end

  nacl_family Sodium::Box, :Curve25519XSalsa20Poly1305, :ref do |constants, methods|
    constants.update(
      :version        => '-',
      :publickeybytes => 32,
      :secretkeybytes => 32,
      :beforenmbytes  => 32,
      :noncebytes     => 24,
      :zerobytes      => 32,
      :boxzerobytes   => 16,
      :macbytes       => 16,
    )

    methods.update(
      nil           => [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :pointer, :int ],
      :open         => [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :pointer, :int ],
      :keypair      => [ :pointer, :pointer, :int ],
      :beforenm     => [ :pointer, :pointer, :pointer, :int ],
      :afternm      => [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :int ],
      :open_afternm => [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :int ],
    )
  end

  nacl_default Sodium::Auth, :hmacsha512256
  nacl_default Sodium::Box,  :curve25519xsalsa20poly1305
end
