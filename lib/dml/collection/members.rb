module Dml
  class Collection
    ##
    # Private Class: Base collection wrapper
    #
    class Members

      def first(*args)
        @members.first(*args)
      end

      def last(*args)
        @members.last(*args)
      end

      def each(&block)
        @members.each(&block)
      end

      def map(&block)
        @members.map(&block)
      end

    private

      def initialize(members)
        @members = members
      end

      def pluck_from(values, fields)
        if fields.one?
          field = fields.first

          values.map { |value| get(value, field) }
        else
          values.map { |value| get_many(value, fields) }
        end
      end

      def get(member, attr)
        if member.is_a?(Hash)
          member[attr]
        else
          member.send(attr)
        end
      end

      def get_many(member, attrs)
        if member.is_a?(Hash)
          member.values_at(*attrs)
        else
          attrs.map { |attr| member.send(attr) }
        end
      end

    end
  end
end
