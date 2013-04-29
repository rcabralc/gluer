require "gluer/dsl"

module Gluer
  class RegistrationCollection
    def initialize(context, block)
      @context = context
      @block = block
    end

    def each
      registrations.clear
      dsl.instance_eval(&block)
      registrations.each { |registration| yield(registration) }
    end

    def add(registration)
      registrations << registration
    end

  private
    attr_reader :context, :block

    def registrations
      @registrations ||= []
    end

    def dsl
      @dsl ||= DSL.new(context, self)
    end
  end
end
