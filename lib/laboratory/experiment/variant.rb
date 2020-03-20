module Laboratory
  class Experiment
    class Variant
      attr_reader :id, :percentage, :participant_ids, :events

      def initialize(id:, percentage:, participant_ids: [], events: [])
        @id = id
        @percentage = percentage
        @participant_ids = participant_ids
        @events = events
      end

      def add_participant(user)
        participant_ids << user.id
      end
    end
  end
end
