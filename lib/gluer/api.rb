require "gluer/file_pool"
require "gluer/registration_collection"

module Gluer
  class << self
    def setup(context=nil, &block)
      path = block.binding.eval('__FILE__')
      return unless file = file_pool.get(path)
      collect_registrations(context, block) do |registration|
        file.add_registration(registration)
      end
    end

    def reload
      file_pool.update
    end

  private

    def collect_registrations(context, block)
      RegistrationCollection.new(context, block).each do |registration|
        yield(registration)
      end
    end

    def file_pool
      @file_pool ||= FilePool.new
    end
  end
end
