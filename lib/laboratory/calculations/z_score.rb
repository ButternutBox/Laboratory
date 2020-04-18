module Laboratory
  module Calculations
    module ZScore
      include Math

      # n: Total population
      # p: conversion percentage

      def self.calculate(n1:, p1:, n2:, p2:) # rubocop:disable Metrics/AbcSize, Naming/MethodParameterName, Metrics/MethodLength
        p1_float = p1.to_f
        p2_float = p2.to_f

        n1_float = n1.to_f
        n2_float = n2.to_f

        # Formula for standard error: root(pq/n) = root(p(1-p)/n)
        s1_float = Math.sqrt(p1_float * (1 - p1_float) / n1_float)
        s2_float = Math.sqrt(p2_float * (1 - p2_float) / n2_float)

        # Formula for pooled error of the difference of the means:
        # root(pi*(1-pi)*(1/na+1/nc)
        # pi = (xa + xc) / (na + nc)
        pi = (p2_float * n2_float + p1_float * n1_float) / (n2_float + n1_float)
        s_p = Math.sqrt(pi * (1 - pi) * (1 / n2_float + 1 / n1_float))

        # Formula for unpooled error of the difference of the means:
        # root(sa**2/pi*a + sc**2/nc)
        s_unp = Math.sqrt(s2_float**2 + s1_float**2)

        # Boolean variable decides whether we can pool our variances
        pooled = s2_float / s1_float < 2 && s1_float / s2_float < 2

        # Assign standard error either the pooled or unpooled variance
        se = pooled ? s_p : s_unp

        # Calculate z-score
        z_score = (p2_float - p1_float) / se

        z_score.round(4)
      end
    end
  end
end
