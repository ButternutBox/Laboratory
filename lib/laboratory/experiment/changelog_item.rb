module Laboratory
  class Experiment
    class ChangelogItem
      attr_reader :action, :changes, :timestamp, :actor

      def initialize(action:, changes: [], timestamp:, actor:)
        @action = action
        @changes = changes
        @timestamp = timestamp
        @actor = actor
      end
    end
  end
end
