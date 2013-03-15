require_relative '../sodium'
require 'ffi'

module Sodium::NaCl
  extend FFI::Library

  ffi_lib 'sodium'

  def self.nacl_default(klass, primitive)
    klass.const_set(:DEFAULT, primitive)
  end

  def self.nacl_family(scope, primitive, implementation)
    klass     = scope.const_set primitive, Class.new(scope)
    family    = 'crypto_' + klass.name.split('::')[1..-1].join('_').downcase
    methods   = {}
    constants = {
      :implementation => implementation,
      :primitive      => family.to_s.split('_').last.to_sym,
    }

    scope.implementations[primitive.downcase] = klass

    yield methods, constants

    constants.each do |name, value|
      klass.const_set(name                           .to_s.upcase, value)
      self .const_set(family.to_s.upcase + '_' + name.to_s.upcase, value)
    end

    methods.each do |name, arguments|
      nacl = self
      imp  = [ family, implementation, name ].compact.map(&:to_s).join('_')
      fn   = [ family,                 name ].compact.map(&:to_s).join('_')
      meth = [ 'nacl', name                 ].compact.map(&:to_s).join('_')

      self.attach_function imp, arguments[0..-2], arguments.last
      self.singleton_class.send :alias_method, fn, imp

      klass.singleton_class.send(:define_method, meth) {|*a, &b| nacl.send(fn, *a, &b) == 0 }
    end
  end

  nacl_default Sodium::Auth, :hmacsha512256

  nacl_family Sodium::Auth, :HMACSHA256, :ref do |methods, constants|
    constants[:version]  = '-'
    constants[:bytes]    = 32
    constants[:keybytes] = 32

    methods[nil]     = [ :pointer, :pointer, :ulong_long, :pointer, :int ]
    methods[:verify] = [ :pointer, :pointer, :ulong_long, :pointer, :int ]
  end

  nacl_family Sodium::Auth, :HMACSHA512256, :ref do |methods, constants|
    constants[:version]  = '-'
    constants[:bytes]    = 32
    constants[:keybytes] = 32

    methods[nil]     = [ :pointer, :pointer, :ulong_long, :pointer, :int ]
    methods[:verify] = [ :pointer, :pointer, :ulong_long, :pointer, :int ]
  end

  nacl_default Sodium::Box, :curve25519xsalsa20poly1305

  nacl_family Sodium::Box, :Curve25519XSalsa20Poly1305, :ref do |methods, constants|
    constants[:version]        = '-'
    constants[:publickeybytes] = 32
    constants[:secretkeybytes] = 32
    constants[:beforenmbytes]  = 32
    constants[:noncebytes]     = 24
    constants[:zerobytes]      = 32
    constants[:boxzerobytes]   = 16
    constants[:macbytes]       = 16

    methods[nil]           = [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :pointer, :int ]
    methods[:open]         = [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :pointer, :int ]
    methods[:keypair]      = [ :pointer, :pointer, :int ]
    methods[:beforenm]     = [ :pointer, :pointer, :pointer, :int ]
    methods[:afternm]      = [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :int ]
    methods[:open_afternm] = [ :pointer, :pointer, :ulong_long, :pointer, :pointer, :int ]
  end
end
