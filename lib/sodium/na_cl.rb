require_relative '../sodium'
require 'ffi'

module Sodium::NaCl
  extend FFI::Library

  ffi_lib 'sodium'

  def self.crypto_family(klass, implementation)
    family    = 'crypto_' + klass.name.split('::')[1..-1].join('_').downcase
    methods   = {}
    constants = {
      :implementation => implementation,
      :primitive      => family.to_s.split('_').last.to_sym,
    }

    yield methods, constants

    constants.each do |name, value|
      klass.const_set(name                           .to_s.upcase, value)
      self .const_set(family.to_s.upcase + '_' + name.to_s.upcase, value)
    end

    methods.each do |name, arguments|
      imp  = [ family, implementation, name ].compact.map(&:to_s).join('_')
      fn   = [ family,                 name ].compact.map(&:to_s).join('_')
      meth = [ 'crypto', name || 'new'      ].compact.map(&:to_s).join('_')

      self.attach_function imp, arguments[0..-2], arguments.last
      self.singleton_class.send :alias_method, fn, imp

      klass.send(:define_method, meth) {|*args, &block| Sodium::NaCl.send(fn, *args, &block) }
      klass.send(:protected,     meth)
    end
  end

  crypto_family Sodium::Auth::HMACSHA256, :ref do |methods, constants|
    constants[:version]        = '-'
    constants[:bytes]          = 32
    constants[:keybytes]       = 32

    methods[nil]     = [ :pointer, :pointer, :ulong_long, :pointer, :uchar ]
    methods[:verify] = [ :pointer, :pointer, :ulong_long, :pointer, :uchar ]
  end

  crypto_family Sodium::Auth::HMACSHA512256, :ref do |methods, constants|
    constants[:version]        = '-'
    constants[:bytes]          = 32
    constants[:keybytes]       = 32

    methods[nil]     = [ :pointer, :pointer, :ulong_long, :pointer, :uchar ]
    methods[:verify] = [ :pointer, :pointer, :ulong_long, :pointer, :uchar ]
  end
end
