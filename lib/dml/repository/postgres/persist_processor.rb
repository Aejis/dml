module Dml
  module Repository
    module Postgres
      class PersistProcessor < Dml::Repository::PersistProcessor

        def process_entity(entity)
          attrs = remove_pk(entity.attributes)
          run_callbacks(attrs)
          hstore_keys(attrs)
        end

      private

        ##
        # Private: deletes primary key if it not composite
        #
        # Params:
        # - params {Hash} attributes of entity
        #
        # Examples:
        #
        #     remove_pk({ id: 3, name: 'name' }) # => {name: 'name'}
        #
        # Returns: {Hash} cleared attributes of entity
        #
        def remove_pk(attrs)
          if @primary_keys.size > 1
            attrs
          else
            attrs.reject { |key| @primary_keys.include?(key) }
          end
        end

        def hstore_keys(attrs)
          attrs.each do |k, v|
            attrs[k] = Sequel.hstore(v) if v.is_a?(Hash)
          end
        end

      end
    end
  end
end
