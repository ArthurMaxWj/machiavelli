# frozen_string_literal: true

require_relative '.\action'
require_relative '.\executors'

# represents one move consisting of any number of Actions (only move-actions not other commands)
class Move
  attr_accessor :error

  def self.from(str, table, deck)
    strings = str.split(' ')
    return { ok: false, value: 'At least one action required' } if strings.empty?

    actions = strings.map do |a_str|
      Action.from(a_str) or return { ok: false, value: a_str }
    end


    { ok: true, value: Move.new(actions, table, deck).with_str(strings) }
  end

  def with_str(strs)
    @action_strs = strs
    self
  end

  def initialize(actions, table, deck)
    @actions = actions
    @table = table
    @deck = deck

    @ok = true
    @error = ''

    @affected_cards = []
  end

  def execute
    ua = @actions.find { |a| unknown_action?(a) }
    if ua
      @error = "Unknown action: #{ua.name}"
      return false
    end

    @actions.each_with_index.all? do |a, i|
      @affecting_action = @action_strs[i]
      action_valid?(a) && perform_action(a)
    end
  end

  def run
    { success: execute, error: @error,
      table: @table, deck: @deck,
      affected_cards: @affected_cards, affecting_action: @affecting_action,
      actions: @actions }
  end

  def action_valid?(action)
    action => {origin:, destination:}

    check_if_posseses?(action, origin, destination)
  end

  def check_if_posseses?(action, origin, destination)
    exe = executor_of(action).new(action, origin, destination)

    p = Possesing.new(exe.requirements, @table, @deck, @affected_cards).check
    p => {valid:, error:, affected_cards:}

    if p[:valid]
      @affected_cards = affected_cards
      true
    else
      @error = error
      false
    end
  end

  def perform_action(action)
    exe = executor_of(action)

    exe.new(action, @table, @deck).perform => {table:, deck:, error:}
    @error = error
    return false unless error.nil?

    @table = table
    @deck = deck
    true
  end

  private

  def executors
    [MoveCardExecutor, PutCardExecutor, NewCombinationExecutor, SplitCombinationExecutor]
  end

  def executor_of(action)
    executors.find do |e|
      e.intended == action.name
    end
  end

  def unknown_action?(action)
    !Action::ACTION_TYPES.include?(action.name)
  end
end

# checks whetver Executor's requirements are meat
#
# call #chack to validate (not called automatically on initalization)
class Possesing
  attr_reader :reqirements, :error, :affected_cards

  def initialize(reqirements, table, deck, affected_cards)
    @reqirements = reqirements
    @table = table
    @deck = deck
    @affected_cards = affected_cards
  end

  def check
    @valid = posseses?(**reqirements)

    { valid: valid?, error:, affected_cards: }
  end

  def valid?
    @valid
  end

  private

  def cards_valid?(cards)
    cards.all? do |cc|
      comb_idx, card_idx = cc

      if inside?(@table, comb_idx, card_idx)
        @affected_cards += [@table[comb_idx][card_idx]]
        true
      else
        @error = "No such card in combination #{comb_idx}-#{card_idx}"
        false
      end
    end
  end

  def place_valid?(com_place)
    return true unless com_place

    comb_idx, place = com_place

    if inside?(@table, comb_idx, place, permit_extra: true)
      true
    else
      @error = "No such spot: #{comb_idx}-#{place}"
      false
    end
  end

  def deck_cards_valid?(deck_cards)
    deck_cards.all? do |card|
      card = card.last
      if (0..@deck.size - 1).include?(card)
        @affected_cards += [@deck[card]]
        true
      else
        @error = "No such card in deck: .-#{card}"
        false
      end
    end
  end

  def posseses?(com_cards: [], com_place: nil, deck_cards: [], min_cards: 1)
    if com_cards.size != min_cards && deck_cards.size != min_cards
      @error = "Requires #{min_cards} cards"
      return false
    end

    cards_valid?(com_cards) && place_valid?(com_place) && deck_cards_valid?(deck_cards)
  end

  def inside?(array, idx1, idx2, permit_extra: false)
    deeper = array[idx1]
    extra = permit_extra ? 1 : 0 # used to allow for position after last element

    !!deeper && array[idx1].size > (idx2 - extra) && idx2 >= 0
  end
end
