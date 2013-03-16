require 'sodium'

module Sodium::Delegate
  def self.included(base)
    base.send :extend, self.class_methods(base)
  end


  def self.class_methods(base)
    Module.new do
      def inherited(base)
        @_nacl_implementations ||= []
        @_nacl_implementations <<  base
      end

      define_method :primitive do
        self.implementation::PRIMITIVE
      end

      define_method :implementation do |*args|
        # seriously, fuck Ruby 1.8
        raise ArgumentError, "wrong number of arguments (#{args.length} for 0)" if
          args.length > 1

        name = args.first || self::DEFAULT

        self != base ?
          self       :
          @_nacl_implementations.detect {|i| i.primitive == name }
      end

      define_method :new do |*args, &block|
        self == base                             ?
          self.implementation.new(*args, &block) :
          super(*args, &block)
      end
    end
  end

  def primitive
    self.implementation::PRIMITIVE
  end

  protected

  def implementation
    self.class.implementation
  end
end
