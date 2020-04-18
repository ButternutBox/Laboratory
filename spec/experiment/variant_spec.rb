RSpec.describe Laboratory::Experiment::Variant do
  it 'should have an attr_reader called id' do
    variant = described_class.new(id: 1, percentage: 50)
    expect(variant).to have_attr_reader(:id)
  end

  it 'should have an attr_reader called percentage' do
    variant = described_class.new(id: 1, percentage: 50)
    expect(variant).to have_attr_reader(:percentage)
  end

  it 'should have an attr_reader called participant_ids' do
    variant = described_class.new(id: 1, percentage: 50)
    expect(variant).to have_attr_reader(:participant_ids)
  end

  it 'should have an attr_reader called events' do
    variant = described_class.new(id: 1, percentage: 50)
    expect(variant).to have_attr_reader(:events)
  end

  describe '#initialize' do
    context 'when the id is specified' do
      it 'uses that id' do
        id = 1
        variant = described_class.new(id: id, percentage: 50)
        expect(variant.id).to eq(id)
      end
    end

    context 'when the percentage is specified' do
      it 'uses that percentage' do
        percentage = 50
        variant = described_class.new(id: 1, percentage: percentage)
        expect(variant.percentage).to eq(percentage)
      end
    end

    context 'when the participant_ids are specified' do
      it 'uses those participant_ids' do
        participant_ids = [1]
        variant = described_class.new(
          id: 1,
          percentage: 50,
          participant_ids: participant_ids
        )
        expect(variant.participant_ids).to eq(participant_ids)
      end
    end

    context 'when the percentage is specified' do
      it 'uses that percentage' do
        events = [1]
        variant = described_class.new(id: 1, percentage: 50, events: events)
        expect(variant.events).to eq(events)
      end
    end
  end

  describe '#add_participant' do
    it 'adds the user\'s id to the participant_ids' do
      user = Laboratory::User.new(id: 1)
      variant = described_class.new(id: 1, percentage: 50)

      variant.add_participant(user)

      expect(variant.participant_ids).to include(user.id)
    end
  end
end
