require "gluer/registration"
require "gluer/registration_definition"

module Gluer
  def self.define_registration(name)
    definition = RegistrationDefinition.new(name)
    yield definition
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
