# frozen_string_literal: true

require_relative 'combination'

# namespace for all executors
module Executors
  # used to execute a single action
  class Executor
    attr_accessor :action, :table, :deck, :name, :origin, :destination, :error, :covered, :try_mode

    def initialize(action, table, deck, try_mode: false)
      @try_mode = try_mode
      @covered = true
      init(action, table, deck)
    end

    def init(action, table, deck)
      @action = action
      @table = table
      @deck = deck
      action => {name:, origin:, destination:}

      @name = name
      @origin = origin
      @destination = destination
    end

    def requirements
      raise 'Not immplemented'
    end

    def perform
      raise 'Not immplemented'
    end

    def self.intended
      raise 'Not immplemented'
    end

    def intended
      intended
    end
  end

  # executes :move_card action
  class MoveCardExecutor < Executor
    def self.intended
      :move_card
    end

    def requirements
      { com_cards: origin, com_place: destination, min_cards: 1, min_what: 'table' }
    end

    def perform
      d_comb, d_place = destination
      is_same = (origin[0].first == d_comb)
      is_before = (origin[0].last < d_place)
      offset = is_same && is_before ? 1 : 0

      perform_move(d_comb, d_place, offset, origin)
      { table:, deck:, error:, covered: false }
    end

    private

    def perform_move(d_comb, d_place, offset, origin)
      @table[d_comb].insert(d_place - offset, @table[origin[0].first].delete_at(origin[0].last))
    end
  end

  # executes :put_card action
  class PutCardExecutor < Executor
    def self.intended
      :put_card
    end

    def requirements
      { deck_cards: origin, com_place: destination }
    end

    def perform
      d_comb, d_place = destination
      table[d_comb].insert(d_place, deck.delete_at(origin.first.last))
      { table:, deck:, error:, covered: false }
    end
  end

  # executes :new_combination action
  class NewCombinationExecutor < Executor
    def self.intended
      :new_combination
    end

    def requirements
      { deck_cards: origin, min_cards: 3 }
    end

    def perform
      perf_new_combination(origin)
      { table:, deck:, error:, covered: false }
    end

    private

    def perf_new_combination(origin)
      d = deck.dup # we need to preserve original order
      abc = origin.map(&:last)
      a, b, c = abc

      return false unless comb_ok?(abc)


      [a, b, c].sort.each_with_index do |v, idx|
        deck.delete_at(v - idx) # idx offsets by already deleted
      end

      table.push([d[a], d[b], d[c]])
    end

    def comb_ok?(abc)
      comb = Combination.new(abc.map { |ca| deck[ca] })
      return true if comb.valid?

      self.error = comb.error
      false
    end
  end

  # executes :break_combination action
  class BreakCombinationExecutor < Executor
    def self.intended
      :break_combination
    end

    def requirements
      { com_place: destination, min_cards: 0 }
    end

    def perform
      d_comb, d_place = @destination
      @covered = false
      perf_break_combination(d_comb, d_place)
      { table:, deck:, error:, covered: @covered }
    end

    private

    def perf_break_combination(d_comb, d_place)
      no_cards_err and return if d_place.zero? || d_place == table[d_comb].size

      comb = table[d_comb]
      first_comb = comb[0..d_place - 1]
      second_comb = comb[d_place..]

      perf_break_comb_modify(table, d_comb, first_comb, second_comb)
    end

    def perf_break_comb_modify(table, d_comb, first_comb, second_comb)
      table.delete_at(d_comb)
      table.insert(d_comb, first_comb)
      table.insert(d_comb + 1, second_comb)
    end

    def no_cards_err
      self.error = 'One of resulting combinations is empty'
      @covered = try_mode
      try_mode
    end
  end
end
