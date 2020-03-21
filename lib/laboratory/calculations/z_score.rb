module Laboratory
  module Calculations
    module ZScore
      include Math

      # n: Total population
      # p: conversion percentage

      def self.calculate(n1:, p1:, n2:, p2:)
        p_1 = p1.to_f
        p_2 = p2.to_f

        n_1 = n1.to_f
        n_2 = n2.to_f

        # Formula for standard error: root(pq/n) = root(p(1-p)/n)
        s_1 = Math.sqrt(p_1 * (1 - p_1) / n_1)
        s_2 = Math.sqrt(p_2 * (1 - p_2) / n_2)

        # Formula for pooled error of the difference of the means: root(π*(1-π)*(1/na+1/nc)
        # π = (xa + xc) / (na + nc)
        pi = (p_2 * n_2 + p_1 * n_1) / (n_2 + n_1)
        s_p = Math.sqrt(pi * (1 - pi) * (1 / n_2 + 1 / n_1))

        # Formula for unpooled error of the difference of the means: root(sa**2/na + sc**2/nc)
        s_unp = Math.sqrt(s_2**2 + s_1**2)

        # Boolean variable decides whether we can pool our variances
        pooled = s_2 / s_1 < 2 && s_1 / s_2 < 2

        # Assign standard error either the pooled or unpooled variance
        se = pooled ? s_p : s_unp

        # Calculate z-score
        z_score = (p_2 - p_1) / (se)

        z_score.round(4)
      end
    end
  end
end
