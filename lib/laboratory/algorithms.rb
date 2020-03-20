module Laboratory
  module Algorithms
    ALGORITHMS = [
      Laboratory::Algorithms::Random
    ].freeze

    def self.to_class(algorithm_id)
      ALGORITHMS.find { |algorithm_class| algorithm_class.id == algorithm_id }
    end
  end
end
