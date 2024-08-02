# frozen_string_literal: true

# basic displaying methods for ConsoleUi
module Displayers
  def display_board(data, writeable: true)
    out '{'
    display_all_combinations(data.all_cards, writeable)
    display_all_player_decks(data.player_decks, writeable)
    out '}'
  end

  def display_all_combinations(all_cards, writeable)
    out '| All combinations:'
    all_cards.each_with_index do |comb, i| # all combinations:
      cards = "[#{i}] "
      comb.each do |card|
        rep = writeable ? card.printable_representation : card.representation

        cards += "#{rep} "
      end
      out "|     #{cards}"
    end
    out '|     <none yet>' if all_cards.empty?
  end

  def display_all_player_decks(player_decks, writeable)
    player_decks.each_pair do |p, deck| # all cards:
      pname = sym_to_player_name(p)
      out "| Cards of player #{pname}:"
      cards = ''
      deck.each do |card|
        rep = writeable ? card.printable_representation : card.representation
        cards += "#{rep} "
      end
      out "|     #{cards}"
    end
  end

  def display_finish_game(player:, give_up:, player_skips:, winner:)
    if give_up
      out "User #{sym_to_player_name(player)} gave up!"
      out 'Skips:'
      player_skips.each_pair do |p, num|
        out "    #{p}: #{num}"
      end
    else
      out "Player #{sym_to_player_name(winner)} won the game!"
    end
  end

  def display_result(data)
    return if data.uidata.actions.empty?

    all_actions_str = data.uidata.actions.each_with_index.map { |a, i| "[#{i}] #{describe_action(a, data)}" }.join('\n')
    out 'Success:'
    out "	   #{all_actions_str}"
  end
end

# extra action descriptions used with ConsoleUi
module DescribeAction
  def describe_action(action, data)
    desc_each_act(action, data) || '<unknown action>'
  end

  def desc_each_act(action, data)
    case action.name
    when :move_card
      desact_move_card(action, data)
    when :put_card
      desact_put_card(action, data)
    when :new_combination
      desact_new_combination(action, data)
    when :split_combination
      desact_split_combination(action, data)
    end
  end

  def desact_move_card(action, data)
    orig = action.origin.first.first
    dest = action.destination.first

    c, place = action.destination
    place -= 1 if c == orig
    card = data.get(c, place).printable_representation
    "Moving card #{card} from combination #{orig} to combination #{dest}"
  end

  def desact_put_card(action, data)
    card = data.get(*action.destination).printable_representation
    dest = action.destination.first
    "Moving card #{card} from deck to combination #{dest}"
  end

  def desact_new_combination(_action, data)
    last_comb = data.size - 1
    card1, card2, card3 = (0..2).map do |num|
      data.get(last_comb, num).printable_representation
    end

    "New combination created form cards #{card1}, #{card2}, #{card3}"
  end

  def desact_split_combination(action, _data)
    orig = action.origin.first.first
    "Combination #{orig} wa splitinto two new combinations no. #{orig} and #{orig + 1}"
  end
end

# used for IO operations in system console
#
# Contains predefined templates to use by other classes.
class ConsoleUi
  include DescribeAction
  include ::Displayers

  attr_accessor :mode, :store, :stored

  MODES = %i[io i o none].freeze

  def initialize(mode = :io, store: false)
    raise ArgumentError, "Unknown console mode: #{mode}" unless MODES.include?(mode)

    @mode = mode
    @store = store
    @stored = []
  end

  def in?
    mode == :io || mode == :i
  end

  def out?
    mode == :io || mode == :o
  end

  def ask_for_move(player:)
    player_name = sym_to_player_name(player)
    out "Move of player #{player_name} (m<orig>:<dest>):"
    write '>>> '
    written_flush

    getin.strip
  end

  def sym_to_player_name(player_symbol)
    case player_symbol
    when :vvv then "'<blank player>'"
    when :first_player then "'Alex'"
    when :second_player then "'Max'"
    else "'<unknown player>'"
    end
  end

  def error(msg)
    out "Error: #{msg}"
  end

  def space
    out "\n\n"
  end

  def welcome
    out 'Welcome to Machiavelli Game!'
    out 'By AM W'
  end

  def out(str = '')
    # rubocop:disable Rails/Output
    puts str if out?
    # rubocop:enable Rails/Output

    @stored.push(str) if @store
  end

  def reset_stored
    @stored = []
  end

  def getin
    in? ? $stdin.gets : nil
  end

  def write(str = '')
    # rubocop:disable Rails/Output
    print str if out?
    # rubocop:enable Rails/Output

    @stored = [''] if @stored.empty?
    @stored[-1] = @stored[-1] + str if @store
  end

  def written_flush
    $stdout.flush
  end

  def obtain(str, cond, ask_str, &block)
    Obtainer.new(self).obtain(str, cond, ask_str, &block)
  end
end

# Used for asking user for input (depending on console's mode)
class Obtainer
  def initialize(console)
    @console = console
  end

  def obtain(str, cond, ask_str, &block)
    check_if_provided(str, cond, &block) => {result:, already_provided:}
    return result if already_provided
    return false unless @console.in?


    ask_for_it(ask_str, cond, &block) => {result:, success:} # if not we ask for it:
    success ? result : false
  end



  private

  def check_if_provided(str, cond)
    already_provided = str.present? # if given along with
    result = nil
    if already_provided
      r = yield(str)
      result = cond.call(str, r) ? r : nil
    end

    { result:, already_provided: }
  end

  def ask_for_it(ask_str, cond)
    @console.write ask_str
    @console.written_flush
    g = @console.getin.strip

    result = yield(g)
    return { result: nil, success: false } unless cond.call(g, result)

    { result:, success: true }
  end
end
