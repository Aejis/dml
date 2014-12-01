require 'dml/repository/persist_processor'
require 'dml/repository/postgres/persist_processor'

module Dml
  module Repository
    ##
    # Class: provides wrap with CRUD operations for models
    #
    class Resource < Base
      DEFAULT_OPTIONS = {
        default_query: true
      }.freeze

      class << self

        attr_reader :queries

        def persist_processor
          @persist_processor ||= Postgres::PersistProcessor.new(relation, primary_key, on_persist)
        end

        ##
        # Static: get entity by primary key
        #
        # Params:
        # - id {String|Integer} primary key
        #
        # Returns:
        #  - {NilClass} nil if record is not found
        #  - {Entity}   if record found
        #
        def fetch(id)
          result = dataset[search_params(id)]
          result ? entity.new(result) : nil
        end
        alias_method :find, :fetch
        alias_method :[], :fetch

        ##
        # Static: save entities to database
        #
        # Params:
        # - records {Array|Entity} one entity or array of entities for saving
        #
        # Returns: {Array(Entity)} array of inserted items
        #
        def insert(records)
          records = Array(records)

          data = persist_processor.process_insert(records)

          pks = DB[relation].returning(primary_key).multi_insert(data)

          pks.each_with_index.map do |pk, index|
            set_key(records[index], pk)
          end
        end
        alias_method :create, :insert

        ##
        # Static: update attributes of entities in the database
        #
        # Params:
        # - record {Array|Entity} one entity or array of entities for updating
        #
        # Returns: {Integer} count of inserted records
        #
        def update(record)
          records = Array(record)

          result = persist_processor.process_update(records)

          result.data.each_with_index.map do |data, i|
            DB[relation].where(result.pkeys[i]).update(data)
          end.reduce(&:+)
        end

        ##
        # Static: remove entities from database
        #
        # Params:
        # - record {Array|Entity} one entity or array of entities for deletion
        #
        # Returns: {Integer} count of deleted entities
        #
        def destroy(record)
          records = Array(record)

          if composite_key?
            # in case of using composite key we need to call delete for each unqie
            # set of keys.
            records.map { |entity| delete_record(entity) }.reduce(&:+)
          else
            delete_record(records)
          end
        end
        alias_method :delete, :destroy

        ##
        # Static: retuns entities wich belongs to some other entity
        #
        # Params:
        # - reflection {Symbol} - name of other entity model
        # - item       {Entity} - item instance
        #
        # TODO: item can has non standart or composite key
        # TODO: prepared statement
        #
        def belong_to(reflection, item)
          column_name = reflection.to_s + '_id'

          records = dataset.where(column_name.to_sym => item.id).all
          records.map { |record| entity.new(record) }
        end

        ##
        # Static: get collection from array or dataset
        #
        # Params:
        # - array_or_dataset {Array|Sequel::Dataset} Array of hashes or dataset
        #
        # Returns: {Collection}
        #
        def wrap(array_or_dataset)
          collection.new(array_or_dataset, entity)
        end

      protected

        ##
        # Static: make complex query for repositories
        #
        # Params:
        # - name    {Symbol} name of query
        # - options {Hash} options
        #   - default {Boolean} use default query (default: true)
        #   - first   {Boolean} return only first result
        #
        # Yields: block with query params
        #
        # Returns: {Collection}
        #
        def query(name, options={}, &block)
          options = DEFAULT_OPTIONS.merge(options)

          ds = options[:default_query] ? dataset : DB[relation]

          @queries ||= {}
          @queries[name.to_sym] = block

          define_singleton_method(name) do |*args|
            result = Query.new(ds, self).instance_exec(*args, &block).dataset

            if options[:first]
              result = result.first
              result ? entity.new(result) : nil
            else
              wrap(result)
            end
          end
        end

        ##
        # Static: the same as .query but returns only first result
        #
        # Params:
        # - name    {Symbol} name of query
        # - options {Hash} options
        #   - default {Boolean} use default query (default: true)
        #   - first   {Boolean} return only first result
        #
        # Yields: block with query params
        #
        # Returns: {Collection}
        #
        def finder(name, options={}, &block)
          query(name, options.merge(first: true), &block)
        end

        ##
        # Protected: sets or return table name
        #
        # Params:
        # - relation_name {Symbol} - name of table
        #
        # Returns: {Symbol} - name of table
        #
        def relation(relation_name=nil)
          @relation ||= relation_name if relation_name

          @relation
        end

      private

        ##
        # Private: primary key columns name
        #
        # Returns: {Array(Symbol)} - array with names of key columns
        #
        # Examples:
        #
        #     # table has composite key
        #     primary_key # => [:id, :something_id]
        #
        def primary_key
          @primary_key ||= DB.schema(relation).reject { |tuple| !tuple.last[:primary_key] }
            .map(&:first)
        end

        ##
        # Private: return true if table use composite key
        #
        def composite_key?
          @composite_key ||= primary_key.size > 1
        end

        ##
        # Private: extract primary keys from records
        #
        # Params:
        # - record {Entity|Array(Entity)} entity
        #
        # Examples:
        #
        #     bag # => <Bag id=5 ...>
        #     key_params(bag) # => { id: 5 }
        #
        #     # composite key
        #     key_params(note) # => { id: 3, second_id: 5 }
        #
        #     # many items
        #     key_params(bags) # => { id: [3, 4, 5]}
        #
        # Returns: {Hash} primary keys with their values from records
        #
        def key_params(records)
          Array(records).each_with_object({}) do |rec, obj|
            rec.attributes.each do |key, value|
              next unless primary_key.include? key
              obj[key] ||= []
              obj[key] << value
            end
          end
        end

        ##
        # Private: returns search hash for sequel
        #
        # Params:
        # - id {String|Integer|Array(String|Integer)} - id or composite id of record
        #
        # Examples:
        #
        #     search_params(5) # => { id: 5 }
        #
        #     # composite key
        #     search_params([3,4]) # => { id: 3, some_id: 4 }
        #
        # Returns: {Hash} primary keys with their values
        #
        def search_params(id)
          Array(id).each_with_index.map { |id_item, index| { primary_key[index] => id_item } }
        end

        ##
        # Private: deletes record from database
        #
        # Params:
        # - record {Entity|Array(Entity)} - records for deleting
        #
        # Returns: {Integer} - count of deleted records
        #
        def delete_record(record)
          condition = key_params(record)

          DB[relation].where(condition).delete
        end

        ##
        # Private: sets primary key to entity
        #
        # Params:
        # - entity {Entity} - record for inserting
        # - pk {Integer|String} - primary key
        #
        # Examples:
        #
        #     entity = set_key(entity, 5)
        #     entity.id # => 5
        #
        #     item = set_key(item, '(3,6)') # composite key
        #     item.id # => 3
        #     item.other_id # => 6
        #
        # Returns: {Entity} - record with inserted keys
        #
        def set_key(entity, pk)
          pk_array = pk.to_s.gsub(/^\(/, '').gsub(/\)$/, '').split(',')

          primary_key.each_with_index { |key, index| entity[key] = pk_array[index] }

          entity
        end

        ##
        # Private: returns Sequel dataset after running of default query
        #
        # Returns: {Sequel::Dataset}
        #
        def dataset
          set = DB[relation]
          set = Query.new(set, self).instance_exec(&default_query).dataset if default_query

          set
        end

      end
    end
  end
end
