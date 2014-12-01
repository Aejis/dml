module Dml
  class Relation
    UndefinedDependencyError = Class.new(StandardError)

    attr_reader :name

    attr_reader :primary_key

    attr_reader :associations

    attr_reader :dependencies

    def freeze
      @associations.freeze
      @dependencies.freeze

      super
    end

  private

    def initialize(name, pk=nil, associations={})
      @name = name
      @primary_key  = pk.kind_of?(Array) ? pk.map(&:to_sym) : pk.to_sym
      @associations = associations

      @dependencies = Set[]

      associations.values.each do |assoc|
        dependencies.add(assoc.target_relation)
      end

      freeze
    end

  end
end

require 'dml/relation/list'

require 'dml/relation/associations/to_one'
require 'dml/relation/associations/one_to_one'
require 'dml/relation/associations/many_to_one'

require 'dml/relation/dsl'
