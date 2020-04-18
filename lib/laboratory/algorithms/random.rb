module Laboratory
  module Algorithms
    class Random
      def self.pick!(variants)
        variants.min_by { |variant| - variant.percentage * rand }
      end

      def self.id
        'RANDOM'
      end
    end
  end
end
