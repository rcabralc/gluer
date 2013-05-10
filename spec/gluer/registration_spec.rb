require 'spec_helper'
require 'gluer/registration'

describe Gluer::Registration do
  # The lifecycle of a Registration:
  #
  #      instantiation
  #            |
  #            v
  #          commit (commit hook is called with registry factored out from
  #            |     definition)
  #            |
  #            v
  #         rollback (rollback hook is called with the same registry)
  #            |
  #            v
  #     garbage collected
  #
  # And if the same registration is committed more than once or rolled back
  # before being committed, errors raise.

  let(:context) { stub('a context') }
  let(:args)    { [stub('argument')] }
  let(:block)   { lambda { block_called } }

  let(:commit_hook)   { stub('the commit hook',  :call => nil) }
  let(:rollback_hook) { stub('the rollback hook',:call => nil) }
  let(:registry)      { stub('registry') }

  let(:definition) do
    stub(
      :registry_factory => lambda { registry },
      :commit_hook      => commit_hook,
      :rollback_hook    => rollback_hook,
    )
  end

  subject do
    Gluer::Registration.new(definition, context, args, block)
  end

  before do
    stub(:block_called)
  end

  it "starts as uncommitted" do
    expect(subject).to_not be_committed
  end

  it "starts as not rolled back" do
    expect(subject).to_not be_rolled_back
  end

  describe "#commit" do
    it "calls the commit hook with right arguments" do
      commit_hook.should_receive(:call).with(registry, context, *args)
      subject.commit
    end

    it "passes the block as the block argument to the hook" do
      should_receive(:block_called)
      commit_hook.stub(:call) do |*, &given_block|
        given_block.call if given_block
      end
      subject.commit
    end

    it "reports as committed" do
      subject.commit
      expect(subject).to be_committed
    end

    it "rejects further commits" do
      subject.commit
      expect { subject.commit }.to raise_error
    end
  end

  describe "#rollback" do
    before { subject.commit }

    it "calls the rollback hook with right arguments, using same registry" do
      definition.registry_factory.should_not_receive(:call)
      rollback_hook.should_receive(:call).with(registry, context, *args)
      subject.rollback
    end

    it "passes the block as the block argument to the hook" do
      should_receive(:block_called)
      rollback_hook.stub(:call) do |*, &given_block|
        given_block.call if given_block
      end
      subject.rollback
    end

    it "reports as rolled back" do
      subject.rollback
      expect(subject).to be_rolled_back
    end

    it "rejects further rollbacks" do
      subject.rollback
      expect { subject.rollback }.to raise_error
    end

    it "rejects further commits" do
      subject.rollback
      expect { subject.commit }.to raise_error
    end
  end
end
