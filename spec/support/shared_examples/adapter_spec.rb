RSpec.shared_examples 'an adapter' do
  before(:each) do
    subject.delete_all
  end

  describe '#write' do
    it 'should be readable once written' do
      experiment = double(
        'Experiment',
        id: 1,
        algorithm: double('Algorithm', id: 'RANDOM'),
        variants: [
          double(
            'Variant',
            id: 'control',
            percentage: 100,
            participant_ids: [],
            events: []
          )
        ],
        changelog: []
      )
      subject.write(experiment)

      fetched_experiment = subject.read(experiment.id)
      expect(fetched_experiment.id).to eq(experiment.id)
    end
  end

  describe '#read' do
    context 'The key does not exist' do
      it 'returns nil' do
        experiment = double(
          'Experiment',
          id: 1,
          algorithm: double('Algorithm', id: 'RANDOM'),
          variants: [
            double(
              'Variant',
              id: 'control',
              percentage: 100,
              participant_ids: [],
              events: []
            )
          ]
        )
        expect(subject.read(experiment.id)).to be nil
      end
    end

    context 'The key exists' do
      it 'fetches the record' do
        experiment = double(
          'Experiment',
          id: 1,
          algorithm: double('Algorithm', id: 'RANDOM'),
          variants: [
            double(
              'Variant',
              id: 'control',
              percentage: 100,
              participant_ids: [],
              events: []
            )
          ],
          changelog: []
        )
        subject.write(experiment)

        fetched_experiment = subject.read(experiment.id)
        expect(fetched_experiment.id).to eq(experiment.id)
      end
    end
  end

  describe '#read_all' do
    context 'There are no records' do
      it 'returns an empty array' do
        expect(subject.read_all).to eq([])
      end
    end

    context 'there are records' do
      it 'returns the records' do
        experiments = [
          double(
            'Experiment',
            id: 1,
            algorithm: double('Algorithm', id: 'RANDOM'),
            variants: [
              double(
                'Variant',
                id: 'control',
                percentage: 100,
                participant_ids: [],
                events: []
              )
            ],
            changelog: []
          ),
          double(
            'Experiment',
            id: 2,
            algorithm: double('Algorithm', id: 'RANDOM'),
            variants: [
              double(
                'Variant',
                id: 'control',
                percentage: 100,
                participant_ids: [],
                events: []
              )
            ],
            changelog: []
          )
        ]
        experiments.each { |experiment| subject.write(experiment) }

        fetched_experiments = subject.read_all
        expect(fetched_experiments.map(&:id)).to eq(experiments.map(&:id))
      end
    end
  end

  describe '#delete' do
    it 'reading the key returns nil once deleted' do
      experiment = double(
        'Experiment',
        id: 1,
        algorithm: double('Algorithm', id: 'RANDOM'),
        variants: [
          double(
            'Variant',
            id: 'control',
            percentage: 100,
            participant_ids: [],
            events: []
          )
        ],
        changelog: []
      )
      subject.write(experiment)

      subject.delete(experiment.id)

      expect(subject.read(experiment.id)).to be nil
    end
  end

  describe '#delete_all' do
    it 'read_all returns an empty array once deleted' do
      experiments = [
        double(
          'Experiment',
          id: 1,
          algorithm: double('Algorithm', id: 'RANDOM'),
          variants: [
            double(
              'Variant',
              id: 'control',
              percentage: 100,
              participant_ids: [],
              events: []
            )
          ],
          changelog: []
        ),
        double(
          'Experiment',
          id: 2,
          algorithm: double('Algorithm', id: 'RANDOM'),
          variants: [
            double(
              'Variant',
              id: 'control',
              percentage: 100,
              participant_ids: [],
              events: []
            )
          ],
          changelog: []
        )
      ]
      experiments.each { |experiment| subject.write(experiment) }

      subject.delete_all

      expect(subject.read_all).to eq([])
    end
  end
end
