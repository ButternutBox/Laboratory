module Laboratory
  class User
    attr_reader :id

    def initialize(id:)
      @id = id
    end

    def experiments
      Experiment.all.select do |experiment|
        experiment.variants.any? do |variant|
          variant.participant_ids.include?(id)
        end
      end
    end

    def variant_for_experiment(experiment)
      experiment.variants.find do |variant|
        variant.participant_ids.include?(id)
      end
    end
  end
end
