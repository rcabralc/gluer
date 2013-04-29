require 'gluer/ordered_set'

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
      registrations.add(registration)
    end

    def replace(registration_pool)
      @registrations = registration_pool.registrations
    end

    def clear
      @registrations = OrderedSet.new
    end

  protected
    attr_reader :registrations
  end
end
