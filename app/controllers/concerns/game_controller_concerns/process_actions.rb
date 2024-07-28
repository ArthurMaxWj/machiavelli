# frozen_string_literal: true

module GameControllerConcerns
  # adds fucntionality responsible for operations on @board (MachiavelliBoard) for GameController
  module ProcessActions
    extend ActiveSupport::Concern

    included do
      after_action :save_session, except: [:restart]
    end

    def execute
      @ui = nil

      prompt = preview.move
      if prompt.strip == ''
        f(:error, 'No moves yet')
      else
        execute_moves(prompt)
      end

      # DEL go_wait_for_turn and return if remote?

      remote? ? go_wait_for_turn : go_home
    end

    def draw_card
      @board.make_move('d', should_swich_player: true) => {ok:, error:}
      f(:error, error) unless ok

      s(:preview, '')
      go_wait_for_turn and return if remote?

      go_home
    end

    def skip
      @board.make_move('s', should_swich_player: true) => {ok:, error:}
      f(:error, error) unless ok

      s(:preview, '')
      go_home
    end

    def restart
      s(:game_state, '')
      s(:preview, '')
      s(:who_cheated, '')
      s(:first_player, 'Alex') if params[:namestoo] == 'yes'
      s(:second_player, 'Max') if params[:namestoo] == 'yes'

      check_remote_save

      go_home
    end


    private

    def save_session
      return unless @save_data_after

      s(:game_state, @board.data.to_json)
      check_remote_save
    end

    def check_remote_save
      flash[:error] = 'Invalid data: unidentified error' and return false if remote? && !remote_save

      true
    end

    def proceed_execution(proceed, prompt)
      f(:error, 'CANT EXECUTE WITH ERRORS! Experiment with your prompt first.') and return unless proceed

      @board.make_move(prompt) => {ok:, error:}
      f(:error, error) unless ok
      preview.move = '' if ok
    end

    def execute_moves(prompt)
      @board.try_move(prompt) => {try_mode_err_covered:, success:}
      proceed = success && !try_mode_err_covered
      proceed_execution(proceed, prompt)
    end
  end
end
