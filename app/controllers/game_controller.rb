# frozen_string_literal: true

require_relative '..\gamelogic\machiavelliboard'

# web version of MachiavelliGame; conects MachiavelliBoard wit web interface
class GameController < ApplicationController
  include Process
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

   
  def about
  end

  def other_commands_info
  end

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
    ExtraCommands.new(@board.data).cmd(params[:cmd],
                                       params[:args]) => {who_cheated:, helper_out:, success:, error:, data:}

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
    preview.move = params[:prompt] # FIX add sanitize

    go_home
  end
  
  def edit_names
    session[:fplayer] = params[:fplayer]
    session[:splayer] = params[:splayer]

    go_home
  end

  # SHARED WITH OTHER MODULES: -----------------------------------------------------------------------------
  
  def go_home
    redirect_to action: 'index'
    true # for chaining return
  end

  def go_scoreboard
    redirect_to action: 'scoreboard'
    true # for chaining return
  end

  def s(key, val)
    session[key] = val
  end

  def f(key, val)
    flash[key] = val
  end

  def player_name(player)
    case player
    when :first_player
      session[:fplayer].presence || 'Alex'
    when :second_player
      session[:splayer].presence || 'Max'
    else
      '<unknown player>'
    end
  end

  def preview
    @preview_move ||= PreviewMove.new(@board, session[:preview].presence || '')

    @preview_move
  end

  private


  def ready_front
    @player = player_name(@board.data.player)
    @cards_left = @board.data.drawboard.cards.present? # used for draw/skip and give up buttons

    @table = front_table
    @deck = front_deck

    @cur_promt = preview.move
    @helper_out = flash[:helper_out]
    @who_cheated = session[:who_cheated]

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



# ---------------------------------------------------------------------------------------------

# adds fucntionality responsible for operations on @board (MachiavelliBoard) for GameCOntroller
module Process
  def execute
    @ui = nil

    prompt = preview.move
    if prompt.strip == ''
      f(:error, 'No moves yet')
    else
      @board.try_move(prompt) => {try_mode_err_covered:, success:}
      proceed = success && !try_mode_err_covered
      proceed_execution(proceed, prompt)
    end

    go_home
  end

  def draw_card
    @board.make_move('d', should_swich_player: true) => {ok:, error:}
    f(:error, error) unless ok

    go_home
  end

  def skip
    @board.make_move('s', should_swich_player: true) => {ok:, error:}
    f(:error, error) unless ok

    go_home
  end

  def restart
    s(:game_state, '')
    s(:preview, '')
    s(:who_cheated, '')
    s(:fplayer, 'Alex') if params[:restartall] == 'yes'
    s(:splayer, 'Max') if params[:restartall] == 'yes'

    go_home
  end
 

  private

  def proceed_execution(proceed, prompt)
    f(:error, 'CANT EXECUTE WITH ERRORS! Experiment with your prompt first.') and return unless proceed

    @board.make_move(prompt) => {ok:, error:}
    f(:error, error) unless ok
    preview.move = '' if ok
  end
end


# ---------------------------------------------------------------------------------------------



# commands related to transformations used by GameCOntroller
class ExtraCommands
  include TransformationHandler
  attr_accessor :data, :ui

  attr_accessor :helper_out, :who_cheated, :success, :error


  def initialize(data)
    @data = data.deep_duplicate
  end

  def cmd(cmd, args)
    kind = CheatCommandsTransformation::CHEAT_CMDS.include?("%#{cmd}") ? :cheat : :helper
    kind == :cheat ? nil : @ui = ConsoleUI.new(:o, store: true)

    kind == :cheat ? cheat("%#{cmd}", args) : helper("&#{cmd}", args)
  end

  def cheat(cmd, args)
    if CheatCommandsTransformation::CHEAT_CMDS.include?(cmd)
      @success = process_cheat(cmd, args)
    else
      @error = 'Unknown cheat/helper command'
    end

    { success:, error:, who_cheated:, data:, helper_out: nil }
  end

  def helper(cmd, args)
    if HelperCommandsTransformation::CMD_LIST.include?(cmd)
      @success = process_helper(cmd, args)
    else
      @error = 'Unknown cheat/helper command'
    end

    { success:, error:, helper_out:, data:, who_cheated: nil }
  end

  def transformation_list
    @tlist ||= {
      helper_commands: HelperCommandsTransformation.new,
      cheat_commands: CheatCommandsTransformation.new
    }

    @tlist
  end


  private

  def process_cheat(cmd, args)
    cheat_move("#{cmd} #{args}") => {ok:, error:}
    if ok
      @who_cheated = @data.player
      true
    else
      @error = error
      false
    end
  end

  def process_helper(cmd, args)
    helper_move("#{cmd} #{args}") => {ok:, error:}
    if ok
      @helper_out = @ui.stored.join('')
      true
    else
      @error = error
      false
    end
  end

  def cheat_move(move_str)
    e('Not a cheat command') unless handle(:cheat_commands, move_str)

    @data.move_status
  end

  def helper_move(move_str)
    e('Not a helper command') unless handle(:helper_commands, move_str)

    @data.move_status
  end
end


# ---------------------------------------------------------------------------------------------




# handles preview of Move (action-move) before its exsecuted by board
# (used by GameController)
class PreviewMove
  attr_accessor :move

  def initialize(board, move_str)
    @move = move_str
    @board = board
  end

  def load_data
    # return @board.data if move.empty? # no errors for empty move

    @board.try_move(move) => {move_status:, result:}
    @board.success? ? result : @board.data
  end

  def undo_move(refresh_msgs: false)
    cmd = @move.strip

    @move = if cmd.count(' ').positive?
              cmd[..cmd.rindex(' ')] # remove last action and space
            elsif cmd.count(' ').zero?
              ''
            end
    update_data(refresh_msgs:)
  end

  def clear
    @move = ''
  end

  def update_data(refresh_msgs: true)
    result = @board.try_move(@move)
    result => {move_status:, try_mode_err_covered:, result:, error:, success:}

    if refresh_msgs
      @flash_error = error unless success
      @flash_warning = error if try_mode_err_covered && success
    end


    { success:, result: }
  end

  def try_move(cmd)
    res = nil
    if !cmd.empty? && Action.from(cmd)
      @move = "#{@move} #{cmd}".strip # append action
      update_data => { success:, result: }
      res = result
      undo_move unless success
    else
      @flash_error = "Unknown command given: #{cmd}"
    end

    res
  end

  def flash_msgs
    { error: @flash_error, warning: @flash_warning }
  end
end
