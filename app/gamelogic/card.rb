# frozen_string_literal: true

# immutable data class representing sinlge Card
class Card < Data.define(:value, :suit)
  VALUES = %i[a j q k] + (2..10).to_a
  VALUES_MAP = VALUES.zip(VALUES.map(&:to_s)).to_h

  SUITS = %i[spade hearth diamond club].freeze
  SUIT_MAP = { spade: 'S', hearth: 'H', diamond: 'D', club: 'C' }.freeze

  PRINTABLE_SUITS = { spade: "\u2660", hearth: "\u2665", diamond: "\u2666", club: "\u2663" }.freeze
  ORDERING_OF_VALUES = [:a] + (2..10).to_a + %i[j q k]

  def self.in(card_str)
    fr = Card.from(card_str)
    return nil unless fr[:success]

    Card.new(value: fr[:value], suit: fr[:suit])
  end

  def self.of(**card_hash)
    return nil unless card_hash.size == 1

    s, v = card_hash.to_a.first
    Card.new(value: v, suit: s).ok_or_nil
  end

  # def self.from_h(card_hash)
  # Card.new(**card_hash).ok_or_nil
  # end

  def ok?
    Card.correct?(value, suit)
  end

  def ok_or_nil
    ok? ? self : nil
  end

  def self.from(card_str)
    suit_str = card_str[-1..]
    value_str = card_str[..-2]

    suit_str = suit_str.upcase
    value_str = value_str.downcase


    vmi = VALUES_MAP.invert
    smi = SUIT_MAP.invert

    success = vmi.include?(value_str) && smi.include?(suit_str)

    v = success ? vmi[value_str] : :unknown # TODO: maybe not the right way
    s = success ? smi[suit_str] : :unknown
    { value: v, suit: s, success: }
  end

  def self.correct?(value, suit)
    VALUES.include?(value) && SUITS.include?(suit)
  end

  def representation
    VALUES_MAP[value] + SUIT_MAP[suit]
  end

  def printable_representation
    VALUES_MAP[value].upcase + PRINTABLE_SUITS[suit]
  end

  def bigger
    next_val = ORDERING_OF_VALUES[order + 1]
    return nil if next_val.nil? # nil means its :k, no greater

    Card.new(value: next_val, suit:)
  end

  def smaller
    return nil if order.zero? # no smaller than :a

    prev_val = ORDERING_OF_VALUES[order - 1] # nil impossible as arrays can work with nagatve numbers

    Card.new(value: prev_val, suit:)
  end

  def value_greater_than?(other_card)
    order > other_card.order
  end

  def value_less_than?(other_card)
    order < other_card.order
  end

  def self.all_cards
    all = []
    Card::SUITS.each do |s|
      Card::VALUES.each do |v|
        all.push(Card.new(v, s))
      end
    end
    all
  end

  def to_s
    representation
  end

  def to_json(*_args)
    # '"' + representation + '"'
    "\"#{representation}\""
  end

  # same as to_json but works in Rails (active support uses this method instead)
  def as_json(*_args)
    representation
  end

  private

  def order
    ORDERING_OF_VALUES.find_index(value)
  end
end

# def Card!(val, suit)
# raise 'Incorrect card' unless Card.correct?(val, suit)

# Card.new(value: val, suit:)
# end
