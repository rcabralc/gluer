require 'gluer/dsl'

describe Gluer::DSL do
  describe "Gluer.define_registration" do
    let(:commit_block)   { Proc.new { |_, _| commit_called } }
    let(:rollback_block) { Proc.new { |_, _| rollback_called } }
    let(:registry_block) { Proc.new { registry_called } }

    before do
      Gluer.define_registration(:foo, &block)
    end

    after do
      Gluer::DSL.clear
    end

    context "when block given doesn't accept an argument" do
      let(:block) do
        # Just adding these to the current scope.  The block will be
        # instance-eval'ed.
        commit_block   = commit_block()
        rollback_block = rollback_block()
        registry_block = registry_block()

        lambda do
          on_commit(&commit_block)
          on_rollback(&rollback_block)
          registry(&registry_block)
        end
      end

      it "adds the registration" do
        should_receive(:commit_called)
        should_receive(:rollback_called)
        should_receive(:registry_called)

        reg_def = Gluer::DSL.get_registration_definition(:foo)

        reg_def.commit_hook.call(stub('registry'), stub('context'))
        reg_def.rollback_hook.call(stub('registry'), stub('context'))
        reg_def.registry_factory.call
      end
    end

    context "when block given accepts a single argument" do
      let(:block) do
        # Just adding these to the current scope.  The block will be
        # instance-eval'ed.
        commit_block   = commit_block()
        rollback_block = rollback_block()
        registry_block = registry_block()

        lambda do |registration|
          registration.on_commit(&commit_block)
          registration.on_rollback(&rollback_block)
          registration.registry(&registry_block)
        end
      end

      it "adds the registration" do
        should_receive(:commit_called)
        should_receive(:rollback_called)
        should_receive(:registry_called)

        reg_def = Gluer::DSL.get_registration_definition(:foo)

        reg_def.commit_hook.call(stub('registry'), stub('context'))
        reg_def.rollback_hook.call(stub('registry'), stub('context'))
        reg_def.registry_factory.call
      end
    end
  end
end
