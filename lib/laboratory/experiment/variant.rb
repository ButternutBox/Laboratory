module Laboratory
  class Experiment
    class Variant
      attr_accessor :id, :percentage
      attr_reader(
        :_original_id,
        :_original_percentage,
        :participant_ids,
        :events
      )

      def initialize(id:, percentage:, participant_ids: [], events: [])
        @id = id
        @percentage = percentage
        @participant_ids = participant_ids
        @events = events

        @_original_id = id
        @_original_percentage = percentage
      end

      def add_participant(user)
        participant_ids << user.id
      end

      def changeset
        set = {}
        set[:id] = [_original_id, id] if _original_id != id
        set[:percentage] = [_original_percentage, percentage] if _original_percentage != percentage
        set
      end
    end
  end
end
