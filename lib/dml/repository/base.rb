module Dml
  module Repository
    ##
    # Class: provides base methods for Repository
    #
    class Base
      class << self

      protected

        def entity(entity_name=nil)
          @entity = entity_name if entity_name
          @entity
        end

        def collection(collection_class=nil)
          @collection = collection_class if collection_class
          @collection || Dml::Collection
        end

        def default_query(&block)
          @default_query_block = block if block_given?

          @default_query_block
        end

        def on_persist(&block)
          @on_write_block = block if block_given?

          @on_write_block
        end
      end
    end
  end
end
