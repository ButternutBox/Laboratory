module Laboratory
  module Adapters
    class RedisAdapter
      attr_reader :redis

      ALL_EXPERIMENTS_KEYS_KEY = 'SWITCH_ALL_EXPERIMENT_KEYS'.freeze

      def initialize(url:)
        @redis = Redis.new(url: url)

        if !redis.get(ALL_EXPERIMENTS_KEYS_KEY)
          redis.set(ALL_EXPERIMENTS_KEYS_KEY, [])
        end
      end

      def write(experiment)
        redis.set(redis_key(experiment_id: experiment.id), experiment_to_json(experiment))

        # Write to ALL_EXPERIMENTS_KEY_KEY if it isn't already there.
        experiment_ids = JSON.parse(redis.get(ALL_EXPERIMENTS_KEYS_KEY))
        experiment_ids << experiment.id unless experiment_ids.include?(experiment.id)
        redis.set(ALL_EXPERIMENTS_KEYS_KEY, experiment_ids.to_json)
      end

      def read(experiment_id)
        key = redis_key(experiment_id: experiment_id)
        response = redis.get(key)

        return nil if response.nil?
        parse_json_to_experiment(JSON.parse(response))
      end

      def read_all
        experiment_ids = JSON.parse(redis.get(ALL_EXPERIMENTS_KEYS_KEY))
        experiment_ids.map do |experiment_id|
          read(experiment_id)
        end
      end

      def delete(experiment_id)
        key = redis_key(experiment_id: experiment_id)
        redis.del(key)

        # Remove from ALL_EXPERIMENTS_KEY_KEY
        experiment_ids = JSON.parse(redis.get(ALL_EXPERIMENTS_KEYS_KEY))
        experiment_ids.delete(experiment_id)
        redis.set(ALL_EXPERIMENTS_KEYS_KEY, experiment_ids.to_json)
      end

      def delete_all
        experiment_ids = JSON.parse(redis.get(ALL_EXPERIMENTS_KEYS_KEY))
        experiment_ids.each { |experiment_id| delete(experiment_id) }
      end

      private

      def redis_key(experiment_id:)
        "laboratory_#{experiment_id}"
      end

      def experiment_to_json(experiment)
        {
          id: experiment.id,
          algorithm: experiment.algorithm.id,
          variants: experiment_variants_to_hash(experiment.variants),
          changelog: experiment.changelog
        }.to_json
      end

      def experiment_variants_to_hash(variants)
        variants.map do |variant|
          {
            id: variant.id,
            percentage: variant.percentage,
            participant_ids: variant.participant_ids,
            events: experiment_events_to_hash(variant.events)
          }
        end
      end

      def experiment_events_to_hash(events)
        events.map do |event|
          {
            id: event.id,
            event_recordings: experiment_event_recordings_to_hash(event.event_recordings)
          }
        end
      end

      def experiment_event_recordings_to_hash(event_recordings)
        event_recordings.map do |event_recording|
          {
            user_id: event_recording.user_id,
            timestamp: event_recording.timestamp
          }
        end
      end

      def parse_json_to_experiment(json)
        Experiment.new(
          id: json['id'],
          algorithm: Algorithms.to_class(json['algorithm']),
          variants: parse_json_to_experiment_variants(json['variants']),
          changelog: parse_json_to_experiment_changelog_items(json['changelog'])
        )
      end

      def parse_json_to_experiment_variants(variants_json)
        variants_json.map do |json|
          Experiment::Variant.new(
            id: json['id'],
            percentage: json['percentage'],
            participant_ids: json['participant_ids'],
            events: parse_json_to_experiment_events(json['events'])
          )
        end
      end

      def parse_json_to_experiment_changelog_items(changelog_json)
        changelog_json.map do |json|
          Experiment::ChangelogItems.new(
            action: json[:action],
            changes: json[:changes],
            timestamp: json[:timestamp],
            actor: json[:actor]
          )
        end
      end

      def parse_json_to_experiment_events(events_json)
        events_json.map do |json|
          Experiment::Event.new(
            id: json['id'],
            event_recordings: parse_json_to_experiment_event_recordings(json['event_recordings'])
          )
        end
      end

      def parse_json_to_experiment_event_recordings(event_recordings_json)
        event_recordings_json.map do |json|
          Experiment::Event::Recording.new(
            user_id: json['user_id'],
            timestamp: json['timestamp']
          )
        end
      end
    end
  end
end
