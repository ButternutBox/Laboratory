module Laboratory
  class Experiment # rubocop:disable Metrics/ClassLength
    class << self
      def overrides
        @overrides || {}
      end

      def override!(overrides)
        @overrides = overrides
      end

      def clear_overrides!
        @overrides = {}
      end
    end

    class UserNotInExperimentError < StandardError; end
    class ClashingExperimentIdError < StandardError; end
    class MissingExperimentIdError < StandardError; end
    class MissingExperimentAlgorithmError < StandardError; end
    class InvalidExperimentVariantFormatError < StandardError; end
    class IncorrectPercentageTotalError < StandardError; end

    attr_accessor :id, :algorithm
    attr_reader(
      :_original_id,
      :_original_algorithm,
      :variants,
      :changelog
    )

    def initialize(id:, variants:, algorithm: Algorithms::Random, changelog: []) # rubocop:disable Metrics/MethodLength
      @id = id
      @algorithm = algorithm
      @changelog = changelog

      # We want to allow users to input Variant objects, or simple hashes.
      # This also helps when decoding from adapters

      @variants =
        if variants.all? { |variant| variant.instance_of?(Experiment::Variant) }
          variants
        elsif variants.all? { |variant| variant.instance_of?(Hash) }
          variants.map do |variant|
            Variant.new(
              id: variant[:id],
              percentage: variant[:percentage],
              participant_ids: [],
              events: []
            )
          end
        end

      @_original_id = id
      @_original_algorithm = algorithm
    end

    def self.all
      Laboratory.config.adapter.read_all
    end

    def self.create(id:, variants:, algorithm: Algorithms::Random)
      raise ClashingExperimentIdError if find(id)

      experiment = Experiment.new(
        id: id,
        variants: variants,
        algorithm: algorithm
      )

      experiment.save
      experiment
    end

    def self.find(id)
      Laboratory.config.adapter.read(id)
    end

    def self.find_or_create(id:, variants:, algorithm: Algorithms::Random)
      find(id) || create(id: id, variants: variants, algorithm: algorithm)
    end

    def delete
      Laboratory.config.adapter.delete(id)
      nil
    end

    def reset
      @variants = variants.map do |variant|
        Variant.new(
          id: variant.id,
          percentage: variant.percentage,
          participant_ids: [],
          events: []
        )
      end
      save
    end

    def variant(user: Laboratory.config.current_user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return variant_overridden_with if overridden?

      selected_variant =
        variants.find do |variant|
          variant.participant_ids.include?(user.id)
        end

      return selected_variant unless selected_variant.nil?

      variant = algorithm.pick!(variants)
      variant.add_participant(user)

      Laboratory::Config.on_assignment_to_variant&.call(self, variant, user)

      save
      variant
    end

    def assign_to_variant(variant_id, user: Laboratory.config.current_user)
      variants.each do |variant|
        variant.participant_ids.delete(user.id)
      end

      variant = variants.find { |s| s.id == variant_id }
      variant.add_participant(user)

      Laboratory::Config.on_assignment_to_variant&.call(self, variant, user)

      save
      variant
    end

    def record_event!(event_id, user: Laboratory.config.current_user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      variant = variants.find { |s| s.participant_ids.include?(user.id) }
      raise UserNotInExperimentError unless variant

      maybe_event = variant.events.find { |event| event.id == event_id }
      event =
        if !maybe_event.nil?
          maybe_event
        else
          e = Event.new(id: event_id)
          variant.events << e
          e
        end
      event_recording = Event::Recording.new(user_id: user.id)

      event.event_recordings << event_recording

      Laboratory::Config.on_event_recorded&.call(self, variant, user, event)

      save
      event_recording
    end

    def analysis_summary_for(event_id)
      Experiment::AnalysisSummary.new(self, event_id)
    end

    def save
      raise errors.first unless valid?

      unless changeset.empty?
        changelog_item = Laboratory::Experiment::ChangelogItem.new(
          changes: changeset,
          timestamp: Time.now,
          actor: Laboratory::Config.actor
        )

        @changelog << changelog_item
      end
      Laboratory.config.adapter.write(self)
    end

    def valid? # rubocop:disable Metrics/AbcSize
      valid_variants =
        variants.all? do |variant|
          !variant.id.nil? && !variant.percentage.nil?
        end

      valid_percentage_amounts =
        variants.map(&:percentage).sum == 100

      !id.nil? && !algorithm.nil? && valid_variants && valid_percentage_amounts
    end

    private

    def overridden?
      self.class.overrides.key?(id) && !variant_overridden_with.nil?
    end

    def variant_overridden_with
      variants.find { |v| v.id == self.class.overrides[id] }
    end

    def changeset # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      set = {}
      set[:id] = [_original_id, id] if _original_id != id

      if _original_algorithm != algorithm
        set[:algorithm] = [_original_algorithm, algorithm]
      end

      variants_changeset =
        variants.map do |variant|
          { variant.id => variant.changeset }
        end

      variants_changeset.reject! do |change|
        change.values.all?(&:empty?)
      end

      set[:variants] = variants_changeset unless variants_changeset.empty?
      set
    end

    def errors # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      errors = []

      missing_variant_ids =
        variants.any? do |variant|
          variant.id.nil?
        end

      missing_variant_percentages =
        variants.any? do |variant|
          variant.percentage.nil?
        end

      incorrect_percentage_total = variants.map(&:percentage).sum != 100

      errors << MissingExperimentIdError if id.nil?
      errors << MissingExperimentAlgorithmError if algorithm.nil?
      errors << MissingExperimentVariantIdError if missing_variant_ids
      errors << MissingExperimentVariantPercentageError if missing_variant_percentages # rubocop:disable Layout/LineLength
      errors << IncorrectPercentageTotalError if incorrect_percentage_total

      errors
    end
  end
end
