module Dml
  class Relation
    module Associations

      class OneToOne < ToOne

        def type
          :one_to_one
        end

      end

    end
  end
end
