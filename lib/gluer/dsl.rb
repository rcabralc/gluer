require "gluer/registration"
require "gluer/registration_definition"

module Gluer
  def self.define_registration(name, &block)
    definition = RegistrationDefinition.new(name)
    if block.arity == 1
      block.call(definition)
    else
      definition.instance_exec(&block)
    end
    DSL.add_registration_definition(name, definition)
  end

  class DSL
    class << self
      def add_registration_definition(name, definition)
        defined_registrations[name] = definition

        define_method(name) do |*args, &block|
          definition   = DSL.get_registration_definition(name)
          registration = Registration.new(definition, @context, args, block)
          @registration_collection.add(registration)
        end
      end

      def get_registration_definition(name)
        defined_registrations.fetch(name)
      end

      def clear
        @defined_registrations = nil
      end

    private

      def defined_registrations
        @defined_registrations ||= {}
      end
    end

    def initialize(context, registration_collection)
      @context = context
      @registration_collection = registration_collection
    end
  end
end
