# frozen_string_literal: true

require_relative '.\game_data'
require_relative '.\transformations\transformation_handler'
require_relative '.\transformations\control_commands_transformation'
require_relative '.\transformations\move_validation_transformation'
require_relative '.\transformations\helper_commands_transformation'
require_relative '.\transformations\cheat_commands_transformation'
require_relative '.\consoleui'



# generic basic game logic
class MachiavelliBoard
  include TransformationHandler

  attr_accessor :data, :ui

  PLAYERS = GameData.players



  def initialize(data: nil, user_interface: nil)
    init_data
    if !data.nil?
      self.data = data
    else
      distribute_card
    end
    @ui = user_interface
  end

  # def show(str = '')
  #   puts "--- #{str}"
  #   dat_hash.each_pair do |p|
  #     label, value = p
  #     puts "| #{label}: #{value}"
  #   end
  #   puts ';'
  # end

  def reset_game
    reset_data
    distribute_card
  end

  def make_move(move_str, should_swich_player: true)
    return @data.move_status unless process_move(move_str)

    check_win # add perform check?
    @data.switch_player if should_swich_player
    @data.move_status
  end

  def try_move(move_str)
    d = data.deep_duplicate
    # @data.uidata = UIData.fresh

    err =  handle(:move_validation, move_str, true) ? 'At least one action required' : nil

    result = @data.deep_duplicate # store result
    @data = d #  original data

    {
      success: err.ni? && result && result.move_status[:ok],
      error: err || result.move_status[:error],
      result:, move_status: result&.move_status,
      try_mode_err_covered: transformation_list[:move_validation].try_mode_err_covered
    }
  end

  def check_win
    return if gave_up?

    winner = @data.player_decks.find { |_k, v| v.empty? }&.first

    return if winner.nil?

    @data.game_status[:finished] = true
    @data.game_status[:give_up] = false
    @data.game_status[:winner] = winner
  end

  def gave_up?
    @data.game_status[:give_up]
  end

  def won?
    @data.game_status[:winner] != :vvv && !gave_up? && game_ended?
  end

  def game_ended?
    @data.game_status[:finished]
  end

  def transformation_list
    @tlist ||= {
      control_commands: ControlCommandsTransformation.new,
      move_validation: MoveValidationTransformation.new
      # cheat_commands: CheatCommandsTransformation.new
    }

    @tlist
  end


  # def cheat_move(move_str)
  # e('Not a cheat command') unless handle(:cheat_commands, move_str)

  # @data.move_status
  # end

  private

  def init_data
    @data = GameData.fresh
  end

  def reset_data
    init_data
  end

  def distribute_card
    @data.player_decks.each_key do |p|
      # don't use Array.new or it wont draw unique card each time
      @data.player_decks[p] += 3.times.map { @data.drawboard.draw_card }
    end
  end

  def initialize_give_up
    @data.game_status = { finished: true, give_up: true, winner: @data.other_player }
  end

  def all_cards_ok?(cards)
    cards.none?(&:nil?)
  end

  def process_move(move_str)
    data.uidata = UIData.fresh

    return success? if handle(:control_commands, move_str)

    return success? if handle(:move_validation, move_str)

    e('At least one action required')
  end

  def e(msg)
    @data.move_status = { ok: false, error: msg }
    false
  end

  def fine
    @data.move_status = { ok: true, error: nil }
    true
  end
end

# def check_all_cards(cards)
# incorrect_cards = cards.select { |c| !c.ok? }

# for ic in incorrect_cards
# @data_errors += ["Invalid card of value #{ic.value} and suit #{ic.suit}"]
# end

# incorrect_cards.present?
# end

# puts Card.d2.representation

# def c(*arr)
# arr.map { |a| Card.in(a) }
# end

# def test
# mb = MachiavelliBoard.new
## mb.show
# mb.make_move('d')
# mb.show
# mb.make_move('d')
## smb.show
# mb.player_decks[:first_player] = c('5D', '6D', '7D')
# mb.show
# puts '#######################'
# mb.make_move('n.-0,.-1,.-2:_')
# mb.show('n.-0,.-1,.-2:_')

## TODO: better messages if syntax incorrect or no proper data is given in possesses?
# end

## test
