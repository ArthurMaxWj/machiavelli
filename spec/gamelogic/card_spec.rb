# frozen_string_literal: true

# spec/card_spec.rb
require_relative '../../app/gamelogic/card'


describe Card do
  # CLASS METHODS: -----------------------------

  describe '::in' do
    context 'with correct string' do
      let(:good) { '3D' }

      it 'returns valid Card' do
        expect(described_class.in(good).representation).to eql(good)
      end
    end

    context 'with correct case insensitive strings' do
      let(:standard) { 'jH' }
      let(:rightdown) { 'jh' }
      let(:leftup) { 'JH' }
      let(:bothcase) { 'Jh' }

      it 'is correct for each case' do
        all_cases = [standard, rightdown, leftup, bothcase]
        all_cards = all_cases.map { |c| described_class.in(c) }
        errors_found = all_cards.any?(&:nil?)

        expect(errors_found).to be false
      end
    end

    context 'with NOT correct string' do
      let(:bad) { 'bad string' }

      it 'returns nil' do
        expect(described_class.in(bad)).to be_nil
      end
    end
  end

  describe '::of' do
    context 'with correct params' do
      let(:good) { { diamond: 10 } }

      it 'returns valid Card' do
        c = described_class.of(**good)
        expect([c.suit, c.value]).to eql(good.to_a.first)
      end
    end

    context 'with NOT correct string' do
      let(:bad) { { wrong: :param, still: 'bad' } }

      it 'returns nil' do
        c = described_class.of(**bad)
        expect(c).to be_nil
      end
    end
  end

  describe '::all_cards' do
    let(:real_size) { Card::SUITS.size * Card::VALUES.size }
    let(:all_cards) { described_class.all_cards }

    it 'has correct size' do
      expect(all_cards.size).to eql(real_size)
    end

    it 'has no nil values' do
      expect(all_cards.any?(&:nil?)).to be false
    end

    it 'has all cards #ok?' do
      expect(all_cards.all?(&:ok?)).to be true
    end

    it 'has correct value and suit' do
      is_ok = all_cards.all? do |c|
        Card::VALUES.include?(c.value) && Card::SUITS.include?(c.suit)
      end

      expect(is_ok).to be true
    end

    it 'has no duplicates' do
      # copied = all_cards.dup
      # offset = 0
      # is_ok = all_cards.each_with_index.all? do |c, i|
      # copied.delete_at(i-offset)
      # offset += 1
      # !(copied.include?(c))
      # end
      is_ok = all_cards.all? { |c| all_cards.count(c) == 1 }
      expect(is_ok).to be true
    end
  end

  # INSTANCE METHODS: ---------------------

  # describe '#suit'
  describe '#value'

  describe '#ok?' do
    context 'with valid card' do
      let(:good) { sample_card }

      it 'returns true' do
        expect(good.ok?).to be true
      end
    end

    context 'with NOT valid card' do
      let(:bad) { bad_card }


      it 'returns false' do
        expect(bad.ok?).to be false
      end
    end

    # it 'can recreate Card' do
    # expect(good.ok?).to be true
    # end
  end
  # describe '#ok_or_nil?'
end

def sample_card
  # v = Card::VALUES.sample
  # s =Card::SUIT.sample

  Card.all_cards.sample
end

def bad_card
  Card.new(value: 10_000, suit: :wrong)
end
