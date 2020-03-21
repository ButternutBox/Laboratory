module Laboratory
  class Experiment
    class AnalysisSummary
      attr_reader :experiment, :event_id

      def initialize(experiment, event_id)
        @experiment = experiment
        @event_id = event_id
      end

      def highest_performing_variant
        sorted_variants.first
      end

      def lowest_performing_variant
        sorted_variants.last
      end

      def performance_delta_between_highest_and_lowest
        numerator = (conversion_rate_for_variant(highest_performing_variant) -
          conversion_rate_for_variant(lowest_performing_variant))
        denominator = conversion_rate_for_variant(lowest_performing_variant)
        numerator.fdiv(denominator).round(2)
      end

      def confidence_level_in_performance_delta
        Laboratory::Calculations::ConfidenceLevel.calculate(
          n1: participant_count_for_variant(lowest_performing_variant),
          p1: event_total_count_for_variant(lowest_performing_variant),
          n2: participant_count_for_variant(highest_performing_variant),
          p2: event_total_count_for_variant(highest_performing_variant)
        )
      end

      private

      def participant_count_for_variant(variant)
        variant.participant_ids.count
      end

      def event_total_count_for_variant(variant)
        event = event_for_variant(variant)
        event.event_recordings.count
      end

      def conversion_rate_for_variant(variant)
        event_total_count_for_variant(variant)
          .fdiv(participant_count_for_variant(variant))
      end

      def relevant_variants
        experiment.variants.select do |variant|
          variant.events.any? do |event|
            event.id == event_id
          end
        end
      end

      def sorted_variants
        relevant_variants.sort_by { |variant|
          conversion_rate_for_variant(variant)
        }.reverse
      end

      def event_for_variant(variant)
        variant.events.find do |event|
          event.id == event_id
        end
      end
    end
  end
end
