require 'virtus'

module Dml
  ##
  # Class: provides entity for Dml
  #
  class Entity
    include Virtus.model

    def eql?(other)
      attributes == other.attributes
    end
    alias_method :==, :eql?
  end
end
