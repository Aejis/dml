module Dml
  class Relation

    class DSL
      class Relation
        attr_reader :associations

        def key(*names)
          @key = names
        end

        def belongs_to(association, &block)
          assoc_name = association.to_sym
          @associations[assoc_name] = BelongsTo.new(@name, assoc_name, &block).association
        end

        def belongs_to_one(association, &block)
          assoc_name = association.to_sym
          @associations[assoc_name] = BelongsToOne.new(@name, assoc_name, &block).association
        end

        def relation
          Dml::Relation.new(@name, @key, @associations)
        end

      private

        def initialize(name, &block)
          @name = name.to_sym
          @key  = [:id]
          @associations = {}

          instance_eval(&block) if block_given?
        end
      end

      class BelongsTo
        def relation(name)
          @options[:target_relation] = name
        end

        def foreign_key(*keys)
          @options[:foreign_keys] = keys
        end

        def reference_key(*keys)
          @options[:target_keys] = keys
        end

        def association
          klass.new(@source_name, @target_name, @options)
        end

      private

        def initialize(source_name, target_name, &block)
          @source_name = source_name
          @target_name = target_name

          @options = {}

          instance_eval(&block) if block_given?
        end

        def klass
          Dml::Relation::Associations::ManyToOne
        end
      end

      class BelongsToOne < BelongsTo
        def klass
          Dml::Relation::Associations::OneToOne
        end
      end

      attr_reader :result

      def relation(name, &block)
        @relations << Relation.new(name, &block).relation
      end

    private

      def initialize(&block)
        @relations = []
        instance_eval(&block) if block_given?
        @result = Dml::Relation::List.new(@relations)
      end
    end

  end
end
