RSpec.describe Laboratory::Calculations::ZScore do
  describe '#calculate' do
    it 'should return the correct z score' do
      z_score = described_class.calculate(
        n1: 1000,
        p1: 0.09,
        n2: 1000,
        p2: 0.1
      )

      expect(z_score).to eq(0.7626)
    end

    it 'should return the correct z score' do
      z_score = described_class.calculate(
        n1: 700,
        p1: 0.285,
        n2: 700,
        p2: 0.325
      )

      expect(z_score).to eq(1.6254)
    end

    it 'should return the correct z score' do
      z_score = described_class.calculate(
        n1: 700,
        p1: 0.285,
        n2: 700,
        p2: 0.348
      )

      expect(z_score).to eq(2.5341)
    end
  end
end
