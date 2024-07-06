# frozen_string_literal: true

# spec/combination_spec.rb
require_relative '..\..\app\gamelogic\combination'

describe Combination do
  describe '#valid' do
    context 'given iteration' do
      context 'when valid' do
        let(:comb) { smaple_iteration(valid: true) }

        it 'returns true' do
          expect(comb.valid?).to be true
        end
      end

      context 'when NOT valid' do
        let(:comb) { smaple_iteration(valid: false) }

        it 'returns false' do
          expect(comb.valid?).to be false
        end
      end
    end

    context 'given gradation' do
      context 'when valid' do
        let(:comb) { smaple_gradation(valid: true) }

        it 'returns true' do
          expect(comb.valid?).to be true
        end
      end

      context 'when NOT valid' do
        let(:comb) { smaple_gradation(valid: false) }

        it 'returns false' do
          expect(comb.valid?).to be false
        end
      end
    end
  end
end

def smaple_iteration(valid:)
  valid ? sample_valid_iteration : sample_not_valid_iteration
end

def sample_valid_iteration
  cards = Card.all_cards.shuffle
  v = Card::VALUES.sample
  cards = cards.filter { |c| c.value == v }

  rand(3..4)
  cards = adjust_cards(cards, max_size: 3)
  Combination.new(cards)
end

def adjust_cards(cards, max_size:, offset: 0)
  cards.each_with_index do |c, i|
    cards.delete_at(i - offset) if cards.count(c) > 1
  end

  cards.shift until (3..max_size).include?(cards.size)
  cards
end

def sample_not_valid_iteration
  iter = sample_valid_iteration.cards
  swap_idx = rand(iter.size)

  iter[swap_idx].value
  new_val = (Card::VALUES - [iter.first.value]).sample
  s = iter[swap_idx].suit
  iter[swap_idx] = Card.new(value: new_val, suit: s)
  Combination.new(iter)
end

def smaple_gradation(valid:)
  valid ? smaple_valid_gradation : smaple_not_valid_gradation
end

def smaple_valid_gradation
  values_included_right = rand(2..Card::VALUES.size)
  values_included_left = rand(0..values_included_right - 3)
  # values_included_left = 0 if values_included_right == 2 # need 3
  vals = Card::ORDERING_OF_VALUES[values_included_left..values_included_right]
  suit = Card::SUITS.sample

  cards = vals.map do |v|
    Card.new(value: v, suit:)
  end

  Combination.new(cards)
end

def smaple_not_valid_gradation
  grad = smaple_valid_gradation.to_arr
  suit = grad.first.suit


  swap_g_value(grad, suit)
  swap_g_suit(grad, suit)

  Combination.new(grad)
end

def swap_g_value(grad, suit)
  swap_value_idx = rand(grad.size)
  old_val = grad[swap_value_idx]
  new_val = (Card::VALUES - [old_val]).sample
  grad[swap_value_idx] = Card.new(value: new_val, suit:)

  grad
end

def swap_g_suit(grad, suit)
  swap_suit_idx = rand(grad.size)
  old_val = grad[swap_suit_idx].value
  new_suit = (Card::SUITS - [suit]).sample
  grad[swap_suit_idx] = Card.new(value: old_val, suit: new_suit)

  grad
end
