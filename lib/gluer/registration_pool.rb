module Gluer
  class RegistrationPool
    def initialize
      clear
    end

    def commit
      registrations.each(&:commit)
    end

    def rollback
      registrations.each(&:rollback)
    end

    def add(registration)
      registrations.push(registration)
    end

    def replace(registration_pool)
      @registrations = registration_pool.registrations
    end

    def clear
      @registrations = []
    end

  protected
    attr_reader :registrations
  end
end
