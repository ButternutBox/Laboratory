RSpec.describe Laboratory::Experiment::Event do
  it 'should have an attr_reader called id' do
    event = described_class.new(id: 1)
    expect(event).to have_attr_reader(:id)
  end

  it 'should have an attr_reader called event_recordings' do
    event = described_class.new(id: 1)
    expect(event).to have_attr_reader(:event_recordings)
  end

  describe '#initialize' do
    context 'when the id is specified' do
      it 'uses that id' do
        id = 1
        event = described_class.new(id: id)
        expect(event.id).to eq(id)
      end
    end

    context 'when the event_recordings is specified' do
      it 'uses those event_recordings' do
        event_recordings = [1]
        event = described_class.new(id: 1, event_recordings: event_recordings)
        expect(event.event_recordings).to eq(event_recordings)
      end
    end
  end
end
