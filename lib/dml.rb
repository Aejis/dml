require 'sequel'

require 'inflecto'

require 'dml/relation'

##
# Data manipulation layer
# Something like data-mapper on top of Sequel
#
module Dml
  def self.define_relations(&block)
    @relations = Relation::DSL.new(&block)
  end
end

require 'dml/collection'
require 'dml/repository'
require 'dml/entity'
