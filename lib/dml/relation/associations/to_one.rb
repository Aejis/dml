module Dml
  class Relation
    module Associations

      class ToOne

        ##
        # Source relation name
        #
        # Returns: {Symbol}
        #
        attr_reader :source_relation

        ##
        # Association name
        #
        # Returns: {Symbol}
        #
        attr_reader :target_name

        ##
        # Associated relation name
        #
        # Returns: {Symbol}
        #
        attr_reader :target_relation

        ##
        # Source foreign key list
        #
        # Example:
        #
        #     association.foreign_keys #=> [:company_id, :company_country]
        #
        # Returns: {Array(Symbol)}
        #
        attr_reader :foreign_keys

        ##
        # Associated relation primary keys list
        #
        # Example:
        #
        #     association.target_keys #=> [:id, :country_id]
        #
        # Returns: {Array(Symbol)}
        #
        attr_reader :target_keys

        ##
        # Foreign key => primary key list
        #
        # Example:
        #
        #     association.reference_keys #=> { :company_id => :id, :company_country => :country_id }
        #
        # Returns: {Hash}
        #
        attr_reader :reference_keys

        ##
        # Association options
        #
        # Returns: {Hash}
        #
        attr_reader :options

        ##
        # Abstract: Association type
        #
        # Returns: {Symbol}
        #
        def type
          fail(NotImplementedError)
        end

        ##
        # Deeply freeze object
        #
        def freeze
          @options.freeze
          @foreign_keys.freeze
          @target_keys.freeze
          @reference_keys.freeze

          super
        end

      private

        ##
        # Constructor:
        #
        # Params:
        # - source_name {Symbol} source relation name
        # - target_name {Symbol} association name
        # - options {Hash}
        #   - target_relation {Symbol|String} target relation name
        #   - foreign_keys    {Symbol|Array}  source foreign key(s)
        #   - target_keys     {Symbol|Array}  target primary key(s)
        #
        def initialize(source_name, target_name, options={})
          @source_relation = source_name
          @target_name = target_name

          @options = options

          set_target_relation
          set_foreign_keys
          set_target_keys
          set_reference_keys

          freeze
        end

        ##
        # Private: set target relation name
        #
        # If name given in options - take it unchanged,
        # otherwise – pluralize association name
        #
        def set_target_relation
          @target_relation = if options.has_key?(:target_relation)
            options[:target_relation]
          else
            Inflecto.pluralize(target_name)
          end.to_sym
        end

        ##
        # Private: set source relation foreign key list
        #
        def set_foreign_keys
          @foreign_keys = Array(options[:foreign_keys] || "#{target_name}_id").map(&:to_sym)
        end

        ##
        # Private: set target relation primary key list
        #
        def set_target_keys
          @target_keys = Array(options[:target_keys] || :id).map(&:to_sym)
        end

        ##
        # Private: create hash where keys is a source foreign keys
        # and values is a target primary keys
        #
        def set_reference_keys
          @reference_keys = Hash[foreign_keys.zip(target_keys)]
        end
      end

    end
  end
end
