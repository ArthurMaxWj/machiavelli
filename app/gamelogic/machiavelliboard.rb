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

    err =  handle(:move_validation, move_str, true) ? nil : 'At least one action required'

    result = @data.deep_duplicate # store result
    @data = d #  original data

    {
      success: err.nil? && result && result.move_status[:ok],
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
    }

    @tlist
  end

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
