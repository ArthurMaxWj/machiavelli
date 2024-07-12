# frozen_string_literal: true

require_relative 'machiavelli_board'

# interface for machiavelli board and immplementation of related logicgame
class MachiavelliGame
  include TransformationHandler

  attr_accessor :data

  # def self.noww_is(noww)
  # @@noww = noww
  # end

  # def self.noww
  # @@noww
  # end

  def self.start_new_game
    MachiavelliGame.new.start
  end

  def start
    @board = MachiavelliBoard.new(user_interface: ui)
    @data = @board.data # firt move_stauts needs a plce t be written
    ui.welcome

    game_loop
    finish_game
  end

  private

  def game_loop
    return if @board.data.game_status[:finished]

    # d = @board.data
    # dd = GameData.from_json(@board.data.to_json)
    # puts d.wiped == dd.wiped
    # byebug

    ui.space
    ui.display_board(@board.data)
    adv = get_move(should_swich_player: @board.data.uidata.advance_move)
    @board.data.uidata.advance_move = adv

    game_loop
  end

  def get_move(should_swich_player: true)
    str = ui.ask_for_move(player: @board.data.player)

    # cheat/helper commands allow for more moves after (same player has move)
    if (handle(:helper_commands, str) || handle(:cheat_commands, str)) && success?
      Rails.logger.debug ui.error(@data.move_status[:error]) unless success?
      return success?
    end

    delegate_to_board(str, should_swich_player:)
  end

  def delegate_to_board(str, should_swich_player:)
    @board.make_move(str, should_swich_player:) => {ok:, error:}

    unless ok
      ui.error(error)
      return false
    end

    ui.display_result(@board.data)
    true
  end

  def finish_game
    player = @board.data.player
    give_up = @board.data.game_status[:give_up]
    player_skips = @board.data.player_skips
    winner = @board.data.game_status[:winner]

    ui.display_finish_game(player:, give_up:, player_skips:, winner:)
  end

  def ui
    @ui ||= ConsoleUi.new
  end

  # TRANSFORMATIONS --------------

  def transformation_list
    {
      helper_commands: HelperCommandsTransformation.new,
      cheat_commands: CheatCommandsTransformation.new
    }
  end

  def transform(name, _not_data, args)
    @data = @board.data
    yield(name, @data, args)
  end

  def after_transform(result_success)
    @board.data = @data if result_success
  end
end

MachiavelliGame.new.start
