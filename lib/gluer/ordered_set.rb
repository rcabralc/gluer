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

    def -(other)
      raise ArgumentError unless other.is_a?(OrderedSet)
      self.class.new(@collection - other.instance_eval { @collection })
    end
  end
end
