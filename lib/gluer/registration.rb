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
      commit_hook.call(registry, context, *args, &block)
      committed
    end

    def rollback
      rollback_hook.call(registry, context, *args, &block) if committed?
    end

  private
    attr_reader :definition, :context, :args, :block

    def committed
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
