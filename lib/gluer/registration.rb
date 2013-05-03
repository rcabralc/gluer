require "gluer/registration_hook"

module Gluer
  class Registration
    attr_accessor :name

    def initialize(definition, context, args, block)
      @definition = definition
      @context = context
      @args = args
      @block = block
      @committed = false
    end

    def commit
      registry.tap do |registry|
        commit_hook.call(registry, context, *args, &block)
        committed_on(registry)
      end
    end

    def rollback
      if committed?
        rollback_hook.call(registry_when_committed, context, *args, &block)
      end
    end

  private
    attr_reader :definition, :context, :args, :block, :registry_when_committed

    def committed_on(registry)
      @registry_when_committed = registry
      @committed = true
    end

    def committed?
      @committed
    end

    def commit_hook
      definition.commit_hook
    end

    def rollback_hook
      definition.rollback_hook
    end

    def registry
      definition.registry_factory.call
    end
  end
end
