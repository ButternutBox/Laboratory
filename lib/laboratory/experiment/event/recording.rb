module Laboratory
  class Experiment
    class Event
      class Recording
        attr_reader :user_id, :timestamp

        def initialize(user_id:, timestamp: Time.now)
          @user_id = user_id
          @timestamp = timestamp
        end
      end
    end
  end
end
