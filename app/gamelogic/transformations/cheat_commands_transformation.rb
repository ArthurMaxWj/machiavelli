# frozen_string_literal: true

require_relative '.\transformation'
require_relative '..\consoleui'

# adds cheat commands to MAchiavelliGame
class CheatCommandsTransformation < Transformation
  CHEAT_CMDS = %w[%cget %cheat.get %cdraw %cheat.draw %cheat.deck %cdeck].freeze

  # OPTIMIZE: maybe print this? or not...
  # OPTIMIZE maybe create notifs system insted of just attr_reader?
  attr_reader :alredy_not_there


  def handle(args)
    raise ArgumentError, 'Exactly one argument required' unless args.size == 1

    @alredy_not_there = false
    @handled = handle_cheat_commands(args.first)
    hdata
  end

  def handled?
    @handled
  end

  def success?
    @success
  end

  private

  def handle_cheat_commands(str)
    cmd = cmd_of(str)
    return false unless cmd

    @success = handle_command(cmd, str)

    true
  end

  def handle_command(cmd, str)
    card_strs = get_card_strings(str[cmd.size + 1..])
    return false unless card_strs # error with data


    cards = card_strs.map { |c| Card.in(c) }
    return false unless all_cards_ok?(cards, card_strs)

    if %w[%cheat.deck %cdeck].include?(cmd)
      cheat_deck(cards)
    else
      cheat_give(cards, del_cards: str.include?('draw'))
    end
    true
  end

  def cmd_of(str)
    CHEAT_CMDS.find do |s|
      str.start_with?(s)
    end
  end

  def get_card_strings(argline)
    console.obtain(argline, ->(_orig, v) { !v.empty? },
                   'What cards: ') do |card_strs|
      card_strs.split(' ')
    end || e('No cards given')
  end

  def all_cards_ok?(cards, card_strs)
    if cards.any?(&:nil?)
      idx = cards.find_index(nil)
      e("No such card: #{card_strs[idx]}")
      return false
    end
    true
  end

  def cheat_deck(cards, give_to: nil)
    give_to || hdata.player
    hdata.player_decks[hdata.player] = cards
  end

  def cheat_give(cards, del_cards: false, give_to: nil)
    target = give_to || hdata.player
    hdata.player_decks[target] += cards

    drawboard_del(cards) if del_cards
  end

  def drawboard_del(cards)
    hdata.drawboard.cards.size

    cards.each do |c|
      idx = hdata.drawboard.cards.find_index(c)
      @alredy_not_there = true if idx.nil?
      hdata.drawboard.cards.delete_at(idx) unless @alredy_not_there
    end
  end
end
