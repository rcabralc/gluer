require 'gluer'
require 'spec_helper'

describe "Default usage" do
  before(:all) do
    class RegistryClass
      def add(context, foo, bar, &block)
        registration = reg_class.new(context, foo, bar, block)
        registrations << registration
      end

      def del(context, foo, bar, block)
        to_delete = reg_class.new(context, foo, bar, block)
        registrations.delete_if do |registration|
          registration.context == to_delete.context &&
            registration.foo == to_delete.foo &&
            registration.bar == to_delete.bar
        end
      end

      def run(context, foo, bar)
        get(context, foo, bar).each do |registration|
          registration.block.call(context)
        end
      end

      def get(context, foo, bar)
        registrations.select do |registration|
          registration.context == context &&
            registration.foo == foo &&
            registration.bar == bar
        end
      end

      def registrations
        @registrations ||= []
      end

      def reg_class
        Struct.new(:context, :foo, :bar, :block)
      end
    end

    Registry = RegistryClass.new

    Gluer.define_registration(:smart_registration) do |registration|
      registration.on_commit do |reg, context, foo, bar, &block|
        reg.add(context, foo, bar, &block)
      end
      registration.on_rollback do |reg, context, foo, bar, &block|
        reg.del(context, foo, bar, block)
      end
      registration.registry { Registry }
    end

    f = File.open("temp_code.rb", "w")
    f.write(<<-CODE)
      require 'gluer'
      Context = Object.new
      Gluer.setup(Context) do
        smart_registration 'foo', 'bar' do |target|
          target.registration_ran
        end
      end
    CODE
    f.close
  end

  after(:all) do
    Object.send(:remove_const, :Registry)
    Object.send(:remove_const, :RegistryClass)
    File.unlink('temp_code.rb')
  end

  after do
    Object.send(:remove_const, :Context) if defined?(Context)
  end

  it "registers stuff within registries" do
    Gluer.reload
    Context.should_receive(:registration_ran)
    Registry.run(Context, 'foo', 'bar')
  end

  context "when the file changes and is reloaded" do
    before do
      Gluer.reload

      f = File.open("temp_code.rb", "w")
      f.write(<<-CODE)
        require 'gluer'
        Context = Object.new
        Gluer.setup(Context) do
          smart_registration 'foo', 'bar' do |target|
            target.new_registration_ran
          end
        end
      CODE
      f.close

      Object.send(:remove_const, :Context)
    end

    it "reloads the registration, replacing the old one" do
      Gluer.reload

      Context.should_not_receive(:registration_ran)
      Context.should_receive(:new_registration_ran)

      Registry.run(Context, 'foo', 'bar')
    end
  end

  context "when the file changes and is reloaded without any registration" do
    before do
      Gluer.reload

      f = File.open("temp_code.rb", "w")
      f.write(<<-CODE)
        require 'gluer'
      CODE
      f.close

      @old_context = Object::Context
      Object.send(:remove_const, :Context)
    end

    it "reloads the file and unregisters the old registration" do
      Gluer.reload
      Registry.get(@old_context, 'foo', 'bar').should be_empty
    end
  end
end
