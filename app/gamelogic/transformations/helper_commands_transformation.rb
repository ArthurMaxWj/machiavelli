# frozen_string_literal: true

require_relative '.\transformation'
require_relative '..\consoleui'


# adds helper commands to MAchiavelliGame
class HelperCommandsTransformation < Transformation
  CMD_LIST = ['...', '&deck', '&comb'].freeze

  attr_accessor :console_mode

  def handle(args)
    raise ArgumentError, 'Exactly one argument required' unless args.size == 1

    # raise ArgumentError, "Missing key ':game_data' from hash arg 'extra'" unless extra.key?(:game_data)

    @handled = handle_helper_commands(args.first)
    hdata.uidata.advance_move = false if handled?
    hdata
  end

  def handled?
    @handled
  end

  def success?
    @success
  end

  private

  def handle_helper_commands(str)
    cmd = CMD_LIST.find { |c| str.start_with?(c) }
    return false unless cmd

    arg = str[cmd.size..]

    exec_cmd(cmd, arg)

    true
  end

  def exec_cmd(name, arg)
    @success = case name
               when '...'
                 helpercmd_affected
               when '&deck'
                 helpercmd_inspect_deck
               else # for '&comb'
                 helpercmd_inspect_comb(arg.strip)
               end
  end

  def helpercmd_affected
    affected_cards = hdata.uidata.affected_cards.map do |c|
      "#{c.printable_representation} "
    end.join(' ')

    affecting_action = hdata.uidata.affecting_action

    display_affected(affected_cards, affecting_action)

    true
  end

  def helpercmd_inspect_deck
    d = hdata.player_decks[hdata.player]
    d.size > 10 ? 5 : 3
    console.out (d.each_with_index.map do |c, i|
      "#{c.printable_representation}(#{i})"
    end).join('   ')
    true
  end

  def helpercmd_inspect_comb(str)
    return false if no_comb

    num = console.obtain(str, ->(orig, _v) { orig == orig.to_i.to_s },
                         'What number: ', &:to_i)
    return e('Not a number') unless num == '' || num # error with data

    return e('No such combination') unless num < hdata.size && hdata.size.positive?

    print_comb(num)
    true
  end

  def no_comb
    comb_num = hdata.size
    return unless comb_num.zero?

    console.out 'No combinations yet'
    nil
  end

  def print_comb(num)
    c = hdata.get_comb(num)

    console.out (c.each_with_index.map do |e, i|
      "#{e.printable_representation}(#{i})"
    end).join('   ')
  end

  def display_affected(affected_cards, affecting_action)
    affecting_action = affecting_action.empty? ? '<none>' : "'#{affecting_action}'"

    console.out "Cards affected by #{affecting_action}:"
    console.out "   #{hdata.uidata.affected_cards.empty? ? '<none>' : affected_cards}"
  end
end
