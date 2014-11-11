module Dml
  class Relation
    module Associations

      class ToOne
        attr_reader :source_relation

        attr_reader :target_name

        attr_reader :target_relation

        attr_reader :foreign_keys

        attr_reader :target_keys

        attr_reader :reference_keys

        attr_reader :options

      private

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

        def set_target_relation
          @target_relation = if options.has_key?(:target_relation)
            options[:target_relation]
          else
            Inflecto.pluralize(target_name)
          end.to_sym
        end

        def set_foreign_keys
          @foreign_keys = Array(options[:foreign_keys] || "#{target_name}_id").map(&:to_sym)
        end

        def set_target_keys
          @target_keys = Array(options[:target_keys] || :id).map(&:to_sym)
        end

        def set_reference_keys
          @reference_keys = Hash[foreign_keys.zip(target_keys)]
        end
      end

    end
  end
end
