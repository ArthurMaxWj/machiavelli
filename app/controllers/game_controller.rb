# frozen_string_literal: true

require_relative '../gamelogic/machiavelliboard'
require_relative 'concerns/game_controller_concerns/common_game_back'
require_relative 'concerns/game_controller_concerns/process'
require_relative '../extra_classes/game_controller_extra_classes/extra_commands'


# web version of MachiavelliGame; conects MachiavelliBoard wit web interface
class GameController < ApplicationController
  include GameControllerConcerns::CommonGameBack
  include GameControllerConcerns::Process

  before_action :state_from_session, except: [:restart]
  after_action :save_session, except: [:restart]
  after_action { session[:preview] = preview.move }

  def index
    if @board.data.game_status[:finished]
      redirect_to action: 'scoreboard'
      return
    end

    ready_front
  end

  def about; end

  def other_commands_info; end

  def tryv_move
    preview.try_move("#{params[:cmdname]}#{params[:cmdargs]}")
    relflash

    go_home
  end

  def clear_tryv_move
    preview.clear

    go_home
  end

  def back_tryv_move
    preview.undo_move(refresh_msgs: true) # we dont say errors for empty action
    relflash unless preview.move.strip.empty?

    go_home
  end

  def cmd
    ec = GameControllerExtraClasses::ExtraCommands.new(@board.data).cmd(params[:cmd], params[:args])
    ec => {who_cheated:, helper_out:, success:, error:, data:}

    if success
      @board.data = data
      session[:who_cheated] = who_cheated if who_cheated
      flash[:helper_out] = helper_out if helper_out
    else
      flash[:error] = error
    end

    go_home
  end

  def scoreboard
    go_home and return unless @board.data.game_status[:finished]

    @player = player_name(@board.data.player)
    @give_up = @board.data.game_status[:give_up]
    @player_skips = @board.data.player_skips
    @winner = player_name(@board.data.game_status[:winner])
  end

  def give_up
    @board.data.game_status[:finished] = true
    @board.data.game_status[:give_up] = true

    go_scoreboard
  end

  def edit_prompt
    preview.move = sanitize(params[:prompt])

    go_home
  end

  def edit_names
    session[:fplayer] = params[:fplayer]
    session[:splayer] = params[:splayer]

    go_home
  end


  private


  def ready_front
    @cards_left = @board.data.drawboard.cards.present? # used for draw/skip and give up buttons

    @table = front_table
    @deck = front_deck

    @cur_promt = preview.move
    @helper_out = flash[:helper_out]
    @who_cheated = session[:who_cheated]

    ready_players
  end

  def ready_players
    @current_player = player_name(@board.data.player)
    @player1 = player_name(:first_player)
    @player2 = player_name(:second_player)
  end

  def front_table
    @table = preview.load_data.table.map { |comb_cards| comb_cards.map(&:representation) }
  end

  def front_deck
    preview.load_data.now_deck.map(&:representation)
  end

  def state_from_session
    data = session[:game_state].present? ? GameData.from_json(session[:game_state]) : nil
    @board = MachiavelliBoard.new(data:)
  end

  def save_session
    session[:game_state] = @board.data.to_json
  end

  def relflash
    preview.flash_msgs => {error:, warning:}
    flash[:error] = error if error
    flash[:warning] = warning if warning
  end
end
