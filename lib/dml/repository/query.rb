module Dml
  module Repository

    ##
    # Class: Exception which throws when query method doesn't return Dataset
    #
    NoDatasetError = Class.new(StandardError)

    ##
    # Class: query proxy
    #
    class Query

      attr_reader :dataset, :context

    private

      def initialize(dataset, context)
        @dataset = dataset
        @context = context
      end

      def with(name, *args)
        instance_exec(*args, &context.queries[name])
      end

      def method_missing(method, *args, &block)
        @dataset = @dataset.send(method, *args, &block)

        unless @dataset.is_a?(Sequel::Dataset)
          fail(NoDatasetError, "method #{method.inspect} did not return a dataset")
        end

        self
      end
    end
  end
end
