require 'sodium'

module Sodium::Delegate
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :extend, self.class_methods(base)
  end

  module ClassMethods
    def inherited(base)
      @_nacl_implementations ||= []
      @_nacl_implementations <<  base

      class << base
        undef_method  :implementation=
        define_method(:implementation) { self }
      end
    end

    def primitive
      self.implementation[:PRIMITIVE].to_sym
    end

    def implementation(name = nil)
      name ?               _find_implementation(name) :
        @_nacl_default ||= _find_implementation(self::DEFAULT)
    end

    def implementation=(implementation)
      @_nacl_default = implementation
    end

    private

    def _find_implementation(name)
      @_nacl_implementations.detect {|i| i.primitive == name }
    end
  end

  def self.class_methods(base)
    Module.new do
      define_method :new do |*args, &block|
        return super(*args, &block) unless self == base
        return self.implementation.new(*args, &block)
      end
    end
  end

  def primitive
    self.class.primitive
  end

  protected

  def implementation
    self.class.implementation
  end
end
