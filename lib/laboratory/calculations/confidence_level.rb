module Laboratory
  module Calculations
    module ConfidenceLevel
      def self.calculate(n1:, p1:, n2:, p2:)
        cvr1 = p1.fdiv(n1)
        cvr2 = p2.fdiv(n2)

        z = ZScore.calculate(
          n1: n1,
          p1: cvr1,
          n2: n2,
          p2: cvr2
        )

        percentage_from_z_score(-z).round(4)
      end

      def self.percentage_from_z_score(z)
        return 0 if z < -6.5
        return 1 if z > 6.5

        factk = 1
        sum = 0
        term = 1
        k = 0

        loop_stop = Math.exp(-23)
        while term.abs > loop_stop do
          term = 0.3989422804 * ((-1)**k) * (z**k) / (2 * k + 1) / (2**k) * (z**(k + 1)) / factk
          sum += term
          k += 1
          factk *= k
        end

        sum += 0.5
        1 - sum
      end
    end
  end
end
