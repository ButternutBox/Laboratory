RSpec.describe Laboratory::User do
  it 'should have an attr_reader called id' do
    user = described_class.new(id: 1)
    expect(user).to have_attr_reader(:id)
  end

  describe '#initialize' do
    context 'when the id is specified' do
      it 'uses that id' do
        id = 1
        user = described_class.new(id: id)
        expect(user.id).to eq(id)
      end
    end
  end

  describe '#experiments' do
    context 'when the user is not in any experiments' do
      it 'returns an empty array' do
        user = described_class.new(id: 1)
        expect(user.experiments).to eq([])
      end
    end

    context 'when the user is in an experiment' do
      it 'returns that experiment in the list' do
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
        experiment = Laboratory::Experiment.new(id: 1, variants: variants)
        user = described_class.new(id: 1)

        experiment.assign_to_variant(experiment.variants.first.id, user: user)

        expect(user.experiments).to eq([experiment])
      end
    end
  end

  describe '#variant_for_experiment' do
    context 'when the user is not in the experiments' do
      it 'returns an empty array' do
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
        experiment = Laboratory::Experiment.new(id: 1, variants: variants)
        user = described_class.new(id: 1)
        expect(user.variant_for_experiment(experiment)).to eq(nil)
      end
    end

    context 'when the user is in an experiment' do
      it 'returns that experiment in the list' do
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
        experiment = Laboratory::Experiment.new(id: 1, variants: variants)
        user = described_class.new(id: 1)

        experiment.assign_to_variant(experiment.variants.first.id, user: user)

        expect(user.variant_for_experiment(experiment)).to eq(experiment.variants.first)
      end
    end
  end
end
