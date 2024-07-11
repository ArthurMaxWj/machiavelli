# frozen_string_literal: true

module GameControllerConcerns
  # adds fucntionality responsible for operations on @board (MachiavelliBoard) for GameController
  module Process
    extend ActiveSupport::Concern

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

      s(:preview, '')
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
end
