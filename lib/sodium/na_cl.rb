require 'sodium'
require 'yaml'
require 'ffi'

module Sodium::NaCl
  CONFIG_PATH = File.expand_path('../../../config/nacl_ffi.yml', __FILE__)
  CONFIG      = YAML.load_file(CONFIG_PATH)

  extend FFI::Library

  ffi_lib 'sodium'

  def self.attach_method(klass, delegate, method, implementation)
    self._metaclass(klass).send :define_method, method do |*a, &b|
      delegate.send(implementation, *a, &b) == 0
    end
  end

  def self._load_class(name)
    name.split('::').inject(Object) {|klass, part| klass.const_get(part) }
  end

  def self._metaclass(klass)
    (class << klass; self; end)
  end

  def self._install_default(scope, primitive)
    scope.const_set :DEFAULT, primitive
  end

  def self._install_implementations(scope, configuration)
    configuration[:implementations].each do |config|
      klass          = scope.const_set config[:name], Class.new(scope)
      family         = configuration[:family]
      primitive      = config[:primitive]
      implementation = config[:implementation]

      _install_constants klass, family, primitive, implementation,
        Hash[configuration[:constants].zip(config[:constants])]

      _install_functions klass, family, primitive, implementation,
        configuration[:functions]
    end
  end

  def self._install_constants(klass, family, primitive, implementation, constants)
    constants.update(
      :PRIMITIVE      => primitive,
      :IMPLEMENTATION => implementation,
    )

    constants.each do |name, value|
      family = family.to_s.upcase
      name   = name.to_s.upcase

      self. const_set("#{family}_#{primitive}_#{name}", value)
      klass.const_set(name,                             value)
    end
  end

  def self._install_functions(klass, family, primitive, implementation, methods)
    methods.each do |name, arguments|
      nacl      = self
      imp       = [ family, primitive, implementation, name ].compact.join('_')
      meth      = [ 'nacl',                            name ].compact.join('_')
      arguments = arguments.map(&:to_sym)

      self.attach_function imp,  arguments[0..-2], arguments.last
      self.attach_method   klass, nacl, meth, imp
    end
  end

  CONFIG.each do |configuration|
    scope = self._load_class configuration[:class]

    self._install_default         scope, configuration[:default][:primitive]
    self._install_implementations scope, configuration
  end
end
