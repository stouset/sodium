require 'sodium'
require 'yaml'
require 'ffi'

module Sodium::NaCl
  CONFIG_PATH = File.expand_path('../../../config/nacl_ffi.yml', __FILE__)
  CONFIG      = YAML.load_file(CONFIG_PATH)

  extend FFI::Library

  ffi_lib 'sodium'

  def self._install_default(delegate, configuration)
    family    = configuration[:family]
    method    = _install_function delegate, family, nil, :PRIMITIVE, [ :string ]
    primitive = delegate.send(method)
  rescue FFI::NotFoundError
    primitive = configuration[:primitives].first
  ensure
    delegate.const_set :DEFAULT, primitive.downcase.to_sym
  end

  def self._install_primitives(delegate, configuration)
    configuration[:primitives].each do |primitive|
      subclass = Class.new(delegate) do
        def self.[](name)
          self.const_get(name)
        end
      end

      delegate.const_set primitive, subclass

      _install_constants subclass, configuration[:family], primitive,
        configuration[:constants]

      _install_functions subclass, configuration[:family], primitive,
        configuration[:functions]
    end
  end

  def self._install_constants(subclass, family, primitive, constants)
    constants = constants.each_with_object(
      :PRIMITIVE => :string
    ) {|constant, hash| hash[constant] = :size_t }

    constants.each_pair do |name, type|
      _install_constant(subclass, family, primitive, name, type)
    end
  end

  def self._install_constant(subclass, family, primitive, name, type)
    method = _install_function subclass, family, primitive, name, [ type ]

    family = family.to_s.upcase
    name   = name.to_s.upcase
    value  = subclass.send(method)

    self.    const_set("#{family}_#{primitive}_#{name}", value)
    subclass.const_set(name,                             value)
  end

  def self._install_functions(subclass, family, primitive, methods)
    methods.each do |name, arguments|
      _install_function(subclass, family, primitive, name, arguments, &:zero?)
    end
  end

  def self._install_function(subclass, family, primitive, name, arguments, &converter)
    imp       = [ family, primitive, name ].compact.join('_').downcase
    meth      = [ 'nacl',            name ].compact.join('_').downcase
    arguments = arguments.map(&:to_sym)

    self.attach_function imp, arguments[0..-2], arguments.last
    self.attach_method   imp, self, subclass, meth, &converter

    meth
  end

  def self.attach_method(implementation, nacl, delegate, method)
    self._metaclass(delegate).send :define_method, method do |*a, &b|
      value = nacl.send(implementation, *a, &b)
      block_given? ? yield(value) : value
    end
  end

  def self._load_class(name)
    name.split('::').inject(Object) {|klass, part| klass.const_get(part) }
  end

  def self._metaclass(klass)
    (class << klass; self; end)
  end
end

module Sodium::NaCl
  CONFIG.each do |configuration|
    delegate = self._load_class configuration[:class]

    self._install_default    delegate, configuration
    self._install_primitives delegate, configuration
  end
end
