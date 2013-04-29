module Gluer
  class RegistrationDefinition
    def initialize(name)
      @name = name
    end

    def on_commit(&block)
      @commit_hook = RegistrationHook.new(block)
    end

    def on_rollback(&block)
      @rollback_hook = RegistrationHook.new(block)
    end

    def registry(&block)
      @registry_factory = block
    end

    attr_reader :commit_hook, :rollback_hook, :registry_factory
  end
end
