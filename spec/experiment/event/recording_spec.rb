RSpec.describe Laboratory::Experiment::Event::Recording do
  it 'should have an attr_reader called user_id' do
    recording = described_class.new(user_id: 1)
    expect(recording).to have_attr_reader(:user_id)
  end

  it 'should have an attr_reader called timestamp' do
    recording = described_class.new(user_id: 1)
    expect(recording).to have_attr_reader(:timestamp)
  end

  describe '#initialize' do
    context 'when the user_id is specified' do
      it 'uses that id' do
        id = 1
        recording = described_class.new(user_id: id)
        expect(recording.user_id).to eq(id)
      end
    end

    context 'when the timestamp is specified' do
      it 'uses that timestamp' do
        timestamp = Time.now
        recording = described_class.new(user_id: 1, timestamp: timestamp)
        expect(recording.timestamp).to eq(timestamp)
      end
    end
  end
end
