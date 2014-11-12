require 'tsort'

module Dml
  class Relation
    class List

      class Sorter
        include TSort

        attr_reader :result

      private

        def initialize(relations)
          @relations = relations.each_with_object({}) { |r, h| h[r.name] = r }

          @result = {}

          tsort_each do |item|
            @result[item] = @relations[item]
          end
        end

        def tsort_each_node(&block)
          @relations.keys.each(&block)
        end

        def tsort_each_child(node, &block)
          @relations[node].dependencies.each(&block)
        end
      end

      attr_reader :names

      def get(key)
        @relations[key]
      end

      def to_a
        @array
      end

    private

      def initialize(relations)
        sorter = Sorter.new(relations)

        @relations = sorter.result.freeze
        @names = @relations.keys.freeze
        @array = @relations.values.freeze
      end
    end
  end
end
