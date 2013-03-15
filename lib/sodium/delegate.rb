require_relative '../sodium'

module Sodium::Delegate
  def self.for(klass)
    _nacl_class_methods = Module.new do
      define_method :implementations do
        @_nacl_implementations ||= {}
      end

      define_method :implementation do |name = self::DEFAULT|
        self == klass                ?
          self.implementations[name] :
          self
      end

      define_method :new do |*args, &block|
        self == klass                            ?
          self.implementation.new(*args, &block) :
          super(*args, &block)
      end
    end

    Module.new do
      def primitive
        self.implementation::PRIMITIVE
      end

      protected

      @_nacl_class_methods = _nacl_class_methods

      def implementation
        self.class.implementation
      end

      def self.included(base)
        base.send :extend, @_nacl_class_methods
      end
    end
  end
end
