# frozen_string_literal: true

require_relative '.\card'

# used to verify if a group of cards is correct
class Combination
  attr_reader :cards, :error

  def initialize(all_cards)
    @cards = all_cards
  end

  def size
    @cards.size
  end

  def to_arr
    cards
  end

  def valid?
    no_nil_allowed

    size_check? && duplicates_check? && combination_type_check?
  end

  def check
    valid?
    error
  end

  private

  def size_check?
    if @cards.size < 3
      @error = 'Too small combination: minimum 3 cards'
      return false
    end

    true
  end

  # maybe sb didnt check card crrectness?
  def no_nil_allowed
    raise 'One card is nil' if cards.find_index(nil)
  end

  def duplicates_check?
    @cards.each_with_index do |c, i|
      @cards[i + 1..].each do |d|
        if c == d
          @error = "Duplicate cards are not allowed in the same combination: #{c.representation}"
          return false
        end
      end
    end

    true
  end

  def combination_type_check?
    unless iteration? || gradation?
      @error = 'Neither iteration nor gradation'
      return false
    end

    true
  end

  # same values different suits
  def iteration?
    @cards.all? do |c|
      c.value == @cards.first.value
    end
  end

  def gradation?
    @cards.each_cons(2).all? do |first, second|
      second == first.bigger
    end
  end
end
