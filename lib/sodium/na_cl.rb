require 'sodium'
require 'yaml'
require 'ffi'

module Sodium::NaCl
  CONFIG_PATH = File.expand_path('../../../config/nacl_ffi.yml', __FILE__)
  CONFIG      = YAML.load_file(CONFIG_PATH)

  extend FFI::Library

  ffi_lib 'sodium'

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

  def self._install_default(scope, configuration)
    family    = configuration[:family]
    method    = _install_function scope, family, nil, :PRIMITIVE, [ :string ]
    primitive = scope.send(method)
  rescue FFI::NotFoundError
    primitive = configuration[:primitives].first
  ensure
    scope.const_set :DEFAULT, primitive.downcase.to_sym
  end

  def self._install_primitives(scope, configuration)
    configuration[:primitives].each do |primitive|
      klass = Class.new(scope) do
        def self.[](name)
          self.const_get(name)
        end
      end

      scope.const_set primitive, klass

      _install_constants klass, configuration[:family], primitive,
        configuration[:constants]

      _install_functions klass, configuration[:family], primitive,
        configuration[:functions]
    end
  end

  def self._install_constants(klass, family, primitive, constants)
    constants = constants.each_with_object(
      :PRIMITIVE => :string
    ) {|constant, hash| hash[constant] = :size_t }

    constants.each_pair do |name, type|
      _install_constant(klass, family, primitive, name, type)
    end
  end

  def self._install_constant(klass, family, primitive, name, type)
    method = _install_function klass, family, primitive, name, [ type ]

    family = family.to_s.upcase
    name   = name.to_s.upcase
    value  = klass.send(method)

    self. const_set("#{family}_#{primitive}_#{name}", value)
    klass.const_set(name,                             value)
  end

  def self._install_functions(klass, family, primitive, methods)
    methods.each do |name, arguments|
      _install_function(klass, family, primitive, name, arguments, &:zero?)
    end
  end

  def self._install_function(klass, family, primitive, name, arguments, &converter)
    imp       = [ family, primitive, name ].compact.join('_').downcase
    meth      = [ 'nacl',            name ].compact.join('_').downcase
    arguments = arguments.map(&:to_sym)

    self.attach_function imp, arguments[0..-2], arguments.last
    self.attach_method   imp, self, klass, meth, &converter

    meth
  end

  CONFIG.each do |configuration|
    scope = self._load_class configuration[:class]

    self._install_default    scope, configuration
    self._install_primitives scope, configuration
  end
end
