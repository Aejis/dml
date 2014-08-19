module Dml
  class Collection
    ##
    # Private Class: Collection wrapper for array
    #
    class ArrayMembers < Members

      def sum(field)
        round_if_whole(@members.reduce(0.0) { |a, e| a + get(e, field) })
      end

      def avg(field)
        round_if_whole(sum(field) / length)
      end

      def min(field)
        pluck(field).min
      end

      def max(field)
        pluck(field).max
      end

      def pluck(*fields)
        pluck_from(@members, fields)
      end

      def count
        @members.length
      end
      alias_method :length, :count

      def all
        @members
      end

    private

      def round_if_whole(num)
        int = num.to_i
        int == num ? int : num
      end

    end
  end
end
