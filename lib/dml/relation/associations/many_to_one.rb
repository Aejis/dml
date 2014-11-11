module Dml
  class Relation
    module Associations

      class ManyToOne < ToOne

        def type
          :many_to_one
        end

      end

    end
  end
end
