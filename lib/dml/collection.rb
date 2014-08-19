require 'dml/collection/members'
require 'dml/collection/array_members'
require 'dml/collection/dataset_members'

module Dml
  ##
  # Class: Base collection facade
  #
  # Unified interface for array of attributes or
  # sequel dataset. Performs lazy entity wrapping.
  #
  # Examples:
  #
  #     User  = Class.new { include Anima.new(:name, :email) }
  #     data  = [
  #       { name: 'John', email: 'john@test.com' },
  #       { name: 'July', email: 'july@test.com' }
  #     ]
  #     users = Collection.new(data, User)
  #     users.map { |user| user.name } #=> ['John', 'July']
  #
  class Collection
    include Enumerable

    attr_reader :members, :entity

    ##
    # Get first n elements from collection
    #
    # Examples:
    #
    #     collection.first #=> <User @name='John'>
    #     collection.first(2) #=> [<User @name='John'>, <User @name='July'>]
    #
    # Returns: entity instance or array of instances
    #
    def first(*args)
      element = members.first(*args)

      args.any? ? wrap(element) : wrap_one(element)
    end

    ##
    # Get last n elements from collection
    #
    # Examples:
    #
    #     collection.last #=> <User @name='Josh'>
    #     collection.last(2) #=> [<User @name='July'>, <User @name='Josh'>]
    #
    # Returns: entity instance or array of instances
    #
    def last(*args)
      element = members.last(*args)

      args.any? ? wrap(element) : wrap_one(element)
    end

    ##
    # Get sum of the given attributes
    #
    # Examples:
    #
    #     collection.sum(:age) #=> 66
    #
    # Params:
    # - field {Symbol} name of attribute
    #
    def sum(field)
      members.sum(field)
    end

    ##
    # Get average value from the given attribute
    #
    # Examples:
    #
    #     collection.avg(:age) #=> 22
    #
    # Params:
    # - field {Symbol} name of attribute
    #
    def avg(field)
      members.avg(field)
    end

    ##
    # Get minimum value from the given attribute
    #
    # Examples:
    #
    #     collection.min(:age) #=> 21
    #
    # Params:
    # - field {Symbol} name of attribute
    #
    def min(field)
      members.min(field)
    end

    ##
    # Get maximum value from the given attribute
    #
    # Examples:
    #
    #     collection.min(:age) #=> 23
    #
    # Params:
    # - field {Symbol} name of attribute
    #
    def max(field)
      members.max(field)
    end

    ##
    # Get an array of values
    #
    # Examples:
    #
    #     collection.pluck(:name) #=> ['John', 'July']
    #     collection.pluck(:name, :age) #=> [['John', 21], ['July', 22]]
    #
    # Params:
    # - fields {Array} keys to select
    #
    def pluck(*fields)
      members.pluck(*fields)
    end

    ##
    # Get quantity of members
    #
    # Examples:
    #
    #     collection.count #=> 3
    #
    # Returns: {Integer}
    #
    def count
      members.count
    end
    alias_method :length, :count

    ##
    # Iterate over elements and cache wrapped results
    #
    # Examples:
    #
    #     collection.each { |user| puts user.name }
    #
    def each(&block)
      if wrapped?
        members.each(&block)
      else
        wrap_and_iterate_with(block)
      end
    end

    ##
    # Return an array of all results
    #
    def all
      @members = ArrayMembers.new(wrap(members.all)) unless wrapped?

      members.all
    end

  private

    ##
    # Constructor: wrap array or dataset with collection facade
    #
    # Params:
    # - array_or_dataset {Array|Sequel::Dataset} Array of hashes or dataset
    # - entity           {Class}                 Class which passes hash of attributes
    #
    def initialize(array_or_dataset, entity)
      @wrapped = false
      @entity  = entity
      @members = if array_or_dataset.is_a?(Sequel::Dataset)
        DatasetMembers.new(array_or_dataset)
      else
        ArrayMembers.new(array_or_dataset)
      end
    end

    def wrapped?
      @wrapped
    end

    ##
    # Private: Instantiate entities for given entries
    #
    # Params:
    # - entries {Array} array of hashes with data for entities
    #
    def wrap(entries)
      entries.map { |entry| entity.new(entry) }
    end

    ##
    # Private: Instantiate entity with given data
    #
    # Params:
    # - entry {Hash} data for entity
    #
    def wrap_one(entry)
      wrapped? ? entry : entity.new(entry)
    end

    ##
    # Private: Iterate over entries with given block
    # Block receives instantiated entity as a param. Instantiated
    # entities will be cached.
    #
    # Params:
    # - block {Proc} iterator
    #
    def wrap_and_iterate_with(block)
      wrapped_dataset = members.map do |member|
        wrapped = entity.new(member)
        block.call(wrapped)
        wrapped
      end

      @wrapped = true
      @members = ArrayMembers.new(wrapped_dataset)
    end
  end
end
