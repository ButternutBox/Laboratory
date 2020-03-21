RSpec.describe Laboratory::Calculations::ConfidenceLevel do
  describe '#calculate' do
    it 'should return the correct z score' do
      confidence_level = described_class.calculate(
        n1: 1000,
        p1: 90,
        n2: 1000,
        p2: 100
      )

      expect(confidence_level).to eq(0.7771)
    end

    it 'should return the correct z score' do
      confidence_level = described_class.calculate(
        n1: 700,
        p1: 200,
        n2: 700,
        p2: 228
      )

      expect(confidence_level).to eq(0.9478)
    end

    it 'should return the correct z score' do
      confidence_level = described_class.calculate(
        n1: 700,
        p1: 200,
        n2: 700,
        p2: 250
      )

      expect(confidence_level).to eq(0.9979)
    end
  end
end
