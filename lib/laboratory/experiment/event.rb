module Laboratory
  class Experiment
    class Event
      attr_reader :id, :event_recordings

      def initialize(id:, event_recordings: [])
        @id = id
        @event_recordings = event_recordings
      end
    end
  end
end
