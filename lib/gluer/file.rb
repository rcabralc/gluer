require "gluer/configuration"
require "gluer/registration_pool"

module Gluer
  class File
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def touch
      @touched = true
    end

    def touched?
      !!@touched
    end

    def add_registration(registration)
      new_registration_pool.add(registration)
      touch
    end

    def rollback_all
      registration_pool.rollback
      registration_pool.clear
    end

    def reload
      load_from_source
      if touched?
        registration_pool.rollback
        new_registration_pool.commit
        registration_pool.replace(new_registration_pool)
        new_registration_pool.clear
      end
    end

  private

    def registration_pool
      @registration_pool ||= RegistrationPool.new
    end

    def new_registration_pool
      @new_registration_pool ||= RegistrationPool.new
    end

    def load_from_source
      @touched = false
      Gluer.config.file_loader.call(path)
    end
  end
end
