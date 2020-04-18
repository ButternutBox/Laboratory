# frozen_string_literal: true

Laboratory.adapter = Laboratory::Adapters::MockAdapter.new

RSpec.describe Laboratory::Experiment do
  before(:each) do
    Laboratory.adapter.delete_all
  end

  it 'should have an attr_reader called id' do
    variants = [
      {
        id: 'control',
        percentage: 80
      },
      {
        id: 'variant_a',
        percentage: 20
      }
    ]
    experiment = described_class.new(id: 1, variants: variants)
    expect(experiment).to have_attr_reader(:id)
  end

  it 'should have an attr_reader called variants' do
    variants = [
      {
        id: 'control',
        percentage: 80
      },
      {
        id: 'variant_a',
        percentage: 20
      }
    ]
    experiment = described_class.new(id: 1, variants: variants)
    expect(experiment).to have_attr_reader(:variants)
  end

  it 'should have an attr_reader called algorithm' do
    variants = [
      {
        id: 'control',
        percentage: 80
      },
      {
        id: 'variant_a',
        percentage: 20
      }
    ]
    experiment = described_class.new(id: 1, variants: variants)
    expect(experiment).to have_attr_reader(:algorithm)
  end

  it 'should have an attr_reader called changelog' do
    variants = [
      {
        id: 'control',
        percentage: 80
      },
      {
        id: 'variant_a',
        percentage: 20
      }
    ]
    experiment = described_class.new(id: 1, variants: variants)
    expect(experiment).to have_attr_reader(:changelog)
  end

  describe '#initialize' do
    context 'when the id is specified' do
      it 'uses that id' do
        id = 'experiment'
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        experiment = described_class.new(id: id, variants: variants)
        expect(experiment.id).to eq(id)
      end
    end

    context 'when the algorithm is specified' do
      it 'should be used' do
        algorithm = 'nonsense'
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        experiment = described_class.new(
          id: 1,
          variants: variants,
          algorithm: algorithm
        )
        expect(experiment.algorithm).to eq(algorithm)
      end
    end
  end

  describe '#create' do
    it 'returns an experiment' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      expect(experiment).to be_instance_of(described_class)
    end

    it 'uses the Algorithms::Random if an algortihm is not specified' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      expect(experiment.algorithm).to eq(Laboratory::Algorithms::Random)
    end

    it 'writes the experiment to the storage adapter' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      expect(described_class.find(experiment.id)).to_not eq nil
    end

    context 'when the variants are passed in in the correct format' do
      it 'converts them into Experiment::Variant objects' do
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        experiment = described_class.create(id: 1, variants: variants)

        expect(experiment.variants)
          .to all(be_instance_of Laboratory::Experiment::Variant)
        expect(experiment.variants.first.id).to eq('control')
        expect(experiment.variants.first.percentage).to eq(40)
        expect(experiment.variants[1].id).to eq('variant_a')
        expect(experiment.variants[1].percentage).to eq(60)
      end
    end

    it 'raises an error if there is a preexisting experiment with the same id' do # rubocop:disable Layout/LineLength
      id = 1
      variants = [
        {
          id: 'control',
          percentage: 40
        },
        {
          id: 'variant_a',
          percentage: 60
        }
      ]
      described_class.create(id: id, variants: variants)

      expect { described_class.create(id: id, variants: variants) }
        .to raise_error(Laboratory::Experiment::ClashingExperimentIdError)
    end
  end

  describe '#find' do
    context 'when the experiment exists' do
      it 'returns the experiment' do
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        experiment = described_class.create(id: 1, variants: variants)

        fetched_experiment = described_class.find(experiment.id)

        expect(fetched_experiment.id).to eq(experiment.id)
        expect(fetched_experiment.algorithm).to eq(experiment.algorithm)
        expect(fetched_experiment.variants).to match(experiment.variants)
      end
    end

    context 'when the experiment does not exist' do
      it 'returns nil' do
        expect(described_class.find('none')).to eq(nil)
      end
    end
  end

  describe '#find_or_create' do
    context 'when the experiment exists' do
      it 'returns the experiment' do
        id = 1
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        experiment = described_class.create(id: id, variants: variants)

        different_variants = [
          {
            id: 'control',
            percentage: 20
          },
          {
            id: 'variant_a',
            percentage: 10
          }
        ]

        fetched_experiment = described_class.find_or_create(
          id: id, variants: different_variants
        )

        expect(fetched_experiment.id).to eq(experiment.id)
        expect(fetched_experiment.variants).to match(experiment.variants)
      end
    end

    context 'when the experiment does not exist' do
      it 'creates the experiment' do
        id = 'random'
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        expect(described_class.find(id)).to eq(nil)
        described_class.find_or_create(id: id, variants: variants)
        expect(described_class.find(id)).not_to eq(nil)
      end
    end
  end

  describe '#delete' do
    it 'deletes the experiment from the stoage adapter' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      experiment.delete
      expect(described_class.find(experiment.id)).to be nil
    end
  end

  describe '#reset' do
    it 'resets the participant_ids for all variants' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      user = Laboratory::User.new(id: 1)
      experiment.assign_to_variant(experiment.variants.first.id, user: user)

      experiment.reset

      expect(experiment.variants.first.participant_ids.count).to be 0
    end

    it 'resets the events for all variants' do
      variants = [{ id: 'control', percentage: 100 }]
      experiment = described_class.create(id: 1, variants: variants)
      user = Laboratory::User.new(id: 1)
      experiment.assign_to_variant(experiment.variants.first.id, user: user)

      experiment.record_event!('completed', user: user)

      experiment.reset

      expect(experiment.variants.first.events.count).to be 0
    end
  end

  describe '#variant' do
    context 'when the user is already assigned to a variant' do
      it 'returns that variant' do
        id = 1
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        user = Laboratory::User.new(id: 1)

        experiment = described_class.create(id: id, variants: variants)
        experiment.assign_to_variant(experiment.variants.first.id, user: user)

        expect(experiment.variant(user: user)).to eq(experiment.variants.first)
      end
    end

    context 'when the user is not already assigned to a variant' do
      it 'returns a random variant' do
        id = 1
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        experiment = described_class.create(id: id, variants: variants)

        srand(435) # Seed randomization to produce consistent results
        expected_outputs = %w[variant_a control control variant_a variant_a]

        outputs = 5.times.map do |i|
          user = Laboratory::User.new(id: i)
          experiment.variant(user: user).id
        end

        expect(outputs).to eq(expected_outputs)
      end
    end

    context 'when the experiment is overridden' do
      it 'returns the overridden variant' do
        id = 1
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        variant_to_override_with = 'variant_a'

        experiment = described_class.create(id: id, variants: variants)
        overrides = {}
        overrides[experiment.id] = variant_to_override_with
        described_class.override!(overrides)

        expect(experiment.variant.id).to eq(variant_to_override_with)
      end
    end
  end

  describe '#assign_to_variant' do
    it 'removes the user from their previous variant' do
      id = 1
      variants = [
        {
          id: 'control',
          percentage: 40
        },
        {
          id: 'variant_a',
          percentage: 60
        }
      ]

      experiment = described_class.create(id: id, variants: variants)
      user = Laboratory::User.new(id: 1)
      variant = experiment.assign_to_variant('control', user: user)

      experiment.assign_to_variant('variant_a', user: user)

      expect(variant.participant_ids).to_not include(user.id)
    end

    it 'adds the user to the new variant' do
      id = 1
      variants = [
        {
          id: 'control',
          percentage: 40
        },
        {
          id: 'variant_a',
          percentage: 60
        }
      ]

      experiment = described_class.create(id: id, variants: variants)
      user = Laboratory::User.new(id: 1)
      variant = experiment.assign_to_variant('control', user: user)

      expect(variant.participant_ids).to include(user.id)
    end
  end

  describe '#record_event!' do
    context 'the user is not in the experiment' do
      it 'raises an error' do
        id = 1
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]

        experiment = described_class.new(id: id, variants: variants)
        user = Laboratory::User.new(id: 1)

        expect { experiment.record_event!('completed', user: user) }
          .to raise_error(Laboratory::Experiment::UserNotInExperimentError)
      end
    end

    it 'returns an event recording' do
      id = 1
      variants = [
        {
          id: 'control',
          percentage: 40
        },
        {
          id: 'variant_a',
          percentage: 60
        }
      ]

      experiment = described_class.new(id: id, variants: variants)
      user = Laboratory::User.new(id: 1)
      experiment.assign_to_variant('control', user: user)

      recording = experiment.record_event!('completed', user: user)
      expect(recording)
        .to be_instance_of(Laboratory::Experiment::Event::Recording)
    end
  end

  describe '#save' do
    it 'calls the adapter#write method' do
      id = 1
      variants = [
        {
          id: 'control',
          percentage: 40
        },
        {
          id: 'variant_a',
          percentage: 60
        }
      ]

      experiment = described_class.new(id: id, variants: variants)
      expect(Laboratory.adapter).to receive(:write).with(experiment)
      experiment.save
    end
  end

  describe '#valid?' do
    context 'when the id is nil' do
      it 'is not valid' do
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        experiment = described_class.new(id: nil, variants: variants)
        expect(experiment.valid?).to be false
      end
    end

    context 'when the id is specified' do
      it 'is valid' do
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        experiment = described_class.new(id: 1, variants: variants)
        expect(experiment.valid?).to be true
      end
    end

    context 'when the algorithm is nil' do
      it 'is not valid' do
        variants = [
          {
            id: 'control',
            percentage: 40
          },
          {
            id: 'variant_a',
            percentage: 60
          }
        ]
        experiment = described_class.new(
          id: 1,
          variants: variants,
          algorithm: nil
        )
        expect(experiment.valid?).to be false
      end
    end

    context 'when the variants are in a valid format' do
      context 'when the percentages sum to 100' do
        it 'is valid' do
          variants = [
            {
              id: 'control',
              percentage: 40
            },
            {
              id: 'variant_a',
              percentage: 60
            }
          ]
          experiment = described_class.new(id: 1, variants: variants)
          expect(experiment.valid?).to be true
        end
      end

      context 'when the percentages do not sum to 100' do
        it 'is not valid' do
          variants = [
            {
              id: 'control',
              percentage: 30
            },
            {
              id: 'variant_a',
              percentage: 20
            }
          ]
          experiment = described_class.new(id: 1, variants: variants)
          expect(experiment.valid?).to be false
        end
      end
    end
  end
end
