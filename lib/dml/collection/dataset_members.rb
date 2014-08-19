module Dml
  class Collection
    ##
    # Private Class: Collection wrapper for Sequel::Dataset
    #
    # This is simple proxy which delegates enumerable methods
    # to dataset and restricts usage of query methods
    #
    class DatasetMembers < Members

      def sum(*args)
        @members.sum(*args)
      end

      def avg(field)
        @members.avg(field)
      end

      def min(field)
        @members.min(field)
      end

      def max(field)
        @members.max(field)
      end

      def pluck(*fields)
        vals = @members.select(*fields).all

        pluck_from(vals, fields)
      end

      def count
        @members.count
      end
      alias_method :length, :count

      def all
        @members.all
      end

    end
  end
end
