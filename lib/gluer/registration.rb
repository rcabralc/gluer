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
      @rolled_back = false
    end

    def commit
      raise RuntimeError, 'already committed' if committed?
      commit_hook.call(registry, context, *args, &block)
      mark_committed
    end

    def rollback
      raise RuntimeError, 'not committed' unless committed?
      raise RuntimeError, 'already rolled back' if rolled_back?
      rollback_hook.call(registry, context, *args, &block)
      mark_rolled_back
    end

    def committed?
      @committed
    end

    def rolled_back?
      @rolled_back
    end

  private
    attr_reader :definition, :context, :args, :block

    def committed_on(registry)
      @registry_when_committed = registry
    end

    def mark_committed
      @committed = true
    end

    def mark_rolled_back
      @rolled_back = true
    end

    def commit_hook
      definition.commit_hook
    end

    def rollback_hook
      definition.rollback_hook
    end

    def registry
      @registry ||= definition.registry_factory.call
    end
  end
end
