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

        (class << base; self; end).send :undef_method, :implementation=
      end

      define_method :primitive do
        self.implementation[:PRIMITIVE]
      end

      define_method :implementation= do |implementation|
        @_nacl_default = implementation
      end

      define_method :implementation do |*args|
        # seriously, fuck Ruby 1.8
        raise ArgumentError, "wrong number of arguments (#{args.length} for 0..1)" if
          args.length > 1

        raise ArgumentError, "wrong number of arguments (#{args.length}) for 0)"   if
          args.length != 0 and self != base

        case
          when self != base then self
          when args.empty?  then @_nacl_default ||= _implementation(self::DEFAULT)
          else                                      _implementation(args.first)
        end
      end

      define_method :_implementation do |name|
        @_nacl_implementations.detect {|i| i.primitive == name }
      end

      define_method :new do |*args, &block|
        self == base                             ?
          self.implementation.new(*args, &block) :
          super(*args, &block)
      end

      private :_implementation
    end
  end

  def primitive
    self.implementation[:PRIMITIVE]
  end

  # only for testing
  def _implementation=(implementation)
    @_nacl_implementation = implementation
  end

  protected

  def implementation
    @_nacl_implementation ||= self.class.implementation
  end
end
