module Gluer
  class RegistrationHook
    attr_reader :hook

    def initialize(hook)
      @hook = hook
    end

    def call(registry, context, *args, &block)
      hook.call(registry, context, *args, &block)
    end
  end
end
