module Gluer
  class OrderedSet
    include Enumerable

    def initialize(initial=[])
      @collection = initial
    end

    def each
      @collection.each { |item| yield(item) }
    end

    def add(new)
      @collection.delete_if { |existing| existing == new }
      @collection << new
    end
  end
end
