module Laboratory
  class Experiment
    class UserNotInExperimentError < StandardError; end
    class ClashingExperimentIdError < StandardError; end
    class MissingExperimentIdError < StandardError; end
    class MissingExperimentAlgorithmError < StandardError; end
    class InvalidExperimentVariantFormatError < StandardError; end
    class IncorrectPercentageTotalError < StandardError; end

    attr_reader :id, :variants, :algorithm, :changelog

    def initialize(id:, variants:, algorithm: Algorithms::Random, changelog: [])
      @id = id
      @algorithm = algorithm
      @changelog = changelog

      # We want to allow users to input Variant objects, or simple hashes.
      # This also helps when decoding from adapters

      @variants =
        if variants.all? { |variant| variant.instance_of?(Laboratory::Experiment::Variant) }
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
    end

    def self.all
      Laboratory.config.adapter.read_all
    end

    def self.create(id:, variants:, algorithm: Algorithms::Random)
      raise ClashingExperimentIdError if find(id)

      changelog_item = Laboratory::Experiment::ChangelogItem.new(
        action: :create,
        changes: [],
        timestamp: Time.now,
        actor: Laboratory::Config.actor
      )

      experiment = Experiment.new(
        id: id,
        variants: variants,
        algorithm: algorithm,
        changelog: [changelog_item]
      )

      experiment.write!
      experiment
    end

    def self.find(id)
      Laboratory.config.adapter.read(id)
    end

    def self.find_or_create(id:, variants:, algorithm: Algorithms::Random)
      find(id) || create(id: id, variants: variants, algorithm: algorithm)
    end

    def update(attrs)
      # delete previous key if valid? passes below.
      old_id = id

      # Diff changes

      current_hash = {
        id: id,
        variants: variants.map { |variant|
          {
            id: variant.id,
            percentage: variant.percentage
          }
        },
        algorithm: algorithm
      }

      updated_variants_subhash = attrs[:variants]&.map do |variant|
        {
          id: variant[:id],
          percentage: variant[:percentage]
        }
      end

      updated_hash = {
        id: attrs[:id] || id,
        variants: updated_variants_subhash || current_hash[:variants],
        algorithm: attrs[:algorithm] || algorithm
      }

      changes = current_hash.to_a - updated_hash.to_a
      @id = attrs[:id] if !attrs[:id].nil?
      @variants = attrs[:variants] if !attrs[:variants].nil?
      @algorithm = attrs[:algorithm] if !attrs[:algorithm].nil?

      raise errors.first unless valid?

      changelog_item = Laboratory::Experiment::ChangelogItem.new(
        action: :update,
        changes: changes,
        timestamp: Time.now,
        actor: Laboratory.config.actor
      )

      @changelog << changelog_item

      Laboratory.config.adapter.delete(old_id)
      write!
      self
    end

    def delete
      Laboratory.config.adapter.delete(id)
      nil
    end

    def variant(user: Laboratory.config.current_user)
      selected_variant = variants.find { |variant| variant.participant_ids.include?(user.id)}
      return selected_variant if !selected_variant.nil?

      variant = algorithm.pick!(variants)
      variant.add_participant(user)

      Laboratory::Config.on_assignment_to_variant&.call(self, variant, user)

      write!
      variant
    end

    def assign_to_variant(variant_id, user: Laboratory.config.current_user)
      variants.each do |variant|
        variant.participant_ids.delete(user.id)
      end

      variant = variants.find { |s| s.id == variant_id }
      variant.add_participant(user)

      Laboratory::Config.on_assignment_to_variant&.call(self, variant, user)

      write!
      variant
    end

    def record_event!(event_id, user: Laboratory.config.current_user)
      variant = variants.find { |s| s.participant_ids.include?(user.id) }
      raise UserNotInExperimentError unless variant

      maybe_event = variant.events.find { |event| event.id == event_id }
      event =
        if maybe_event != nil
          maybe_event
        else
          e = Event.new(id: event_id)
          variant.events << e
          e
        end
      event_recording = Event::Recording.new(user_id: user.id)

      event.event_recordings << event_recording

      Laboratory::Config.on_event_recorded&.call(self, variant, user, event)

      write!
      event_recording
    end

    def write!
      raise errors.first unless valid?
      Laboratory.config.adapter.write(self)
    end

    def valid?
      valid_variants =
        variants.all? do |variant|
          !variant.id.nil? && !variant.percentage.nil?
        end

      valid_percentage_amounts =
        variants.map(&:percentage).sum == 100

      !id.nil? && !algorithm.nil? && valid_variants && valid_percentage_amounts
    end

    def errors
      errors = []

      missing_variant_ids = variants.any? do |variant|
        variant.id.nil?
      end

      missing_variant_percentages = variants.any? do |variant|
        variant.percentage.nil?
      end

      incorrect_percentage_total = variants.map(&:percentage).sum != 100

      errors << MissingExperimentIdError if id.nil?
      errors << MissingExperimentAlgorithmError if algorithm.nil?
      errors << MissingExperimentVariantIdError if missing_variant_ids
      errors << MissingExperimentVariantPercentageError if missing_variant_percentages
      errors << IncorrectPercentageTotalError if incorrect_percentage_total

      errors
    end
  end
end
