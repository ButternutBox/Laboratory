module Laboratory
  module Adapters
    class MockAdapter
      attr_accessor :experiment_hash

      def initialize
        @experiment_hash = {}
      end

      def write(experiment)
        experiment_hash[experiment.id] = experiment
      end

      def read_all
        experiment_hash.values
      end

      def read(experiment_id)
        experiment_hash[experiment_id]
      end

      def delete(experiment_id)
        experiment_hash.delete(experiment_id)
      end

      def delete_all
        @experiment_hash = {}
      end
    end
  end
end
