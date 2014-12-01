module Dml
  module Repository
    class PersistProcessor

      Update = Struct.new(:pkeys, :data).freeze

      def process_insert(entities)
        entities.map do |entity|
          process_entity(entity)
        end
      end

      def process_update(entities)
        pkeys = []

        data = entities.map do |entity|
          pkeys << extract_keys(entity)
          process_entity(entity)
        end

        Update.new(pkeys, data)
      end

      def process_entity(entity)
        run_callbacks(entity.attributes.dup)
      end

    private

      def initialize(relation_name, primary_keys, callbacks)
        @relation_name = relation_name
        @primary_keys  = primary_keys
        @callbacks     = callbacks
      end

      def run_callbacks(attrs)
        @callbacks.each do |callback|
          callback.call(attrs)
        end
        attrs
      end

      ##
      # Private: extract primary keys from records
      #
      # Params:
      # - record {Entity} entity
      #
      # Returns: {Hash} primary keys with their values from records
      #
      def extract_keys(entity)
        Hash[@primary_keys.zip(entity.attributes.values_at(*@primary_keys))]
      end

    end
  end
end
