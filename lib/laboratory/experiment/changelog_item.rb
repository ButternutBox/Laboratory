module Laboratory
  class Experiment
    class ChangelogItem
      attr_reader :changes, :timestamp, :actor

      def initialize(changes:, timestamp:, actor:)
        @changes = changes
        @timestamp = timestamp
        @actor = actor
      end
    end
  end
end
