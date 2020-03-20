module Laboratory
  module Algorithms
    class Random
      def self.pick!(variants)
        variants.sort_by { |variant| - variant.percentage * rand() }.first
      end

      def self.id
        'RANDOM'
      end
    end
  end
end
