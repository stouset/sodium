require_relative '../sodium'

module Sodium::Delegate
  def self.for(klass)
    Module.new do
      define_method :implementations do
        @_nacl_implementations ||= {}
      end

      define_method :implementation do |name|
        self.implementations[name]
      end

      define_method :new do |*a, &b|
        self == klass ?
          self.implementation(self::DEFAULT).new(*a, &b) :
          super(*a, &b)
      end
    end
  end
end
