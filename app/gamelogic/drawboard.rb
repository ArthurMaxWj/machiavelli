# frozen_string_literal: true

require_relative 'card'

# store of cards free to give to players
Drawboard = Struct.new(:cards) do
  def init
    self.cards = new_draw_board
    self
  end

  def self.fresh
    Drawboard.new.init
  end

  def new_draw_board
    # we need 2 of each card
    self.cards = Card.all_cards + Card.all_cards
    # in random order
    cards.shuffle
  end

  def draw_card
    cards.shift
  end

  def size
    cards.size
  end

  def deep_duplicate
    copied = dup
    copied.cards = cards.dup
    copied
  end

  def order
    cards.sort! { |a, b| a.representation <=> b.representation }
  end

  def self.props
    [:cards]
  end

  def to_json(*_args)
    to_h.to_json
  end

  # same as to_json but works in Rails (active support uses this method instead)
  def as_json(*_args)
    to_h.as_json
  end

  def self.from_h(hash)
    h = hash.transform_keys(&:to_sym)

    return nil unless h.keys == Drawboard.props

    h[:cards] = h[:cards].map { |c| Card.in(c) }
    return nil if h[:cards].any?(&:nil?)

    Drawboard.new(**h)
  end

  def self.from_json(json_str)
    Drawboard.from_h(JSON.parse(json_str))
  end
end
