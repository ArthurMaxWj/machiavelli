# frozen_string_literal: true

module GameControllerConcerns
  # adds fucntionality responsible for operations on @board (MachiavelliBoard) for GameController
  module ReadyFront
    extend ActiveSupport::Concern

    def ready_front
      @cards_left = @board.data.drawboard.cards.present? # used for draw/skip and give up buttons

      @table = front_table
      @deck = front_deck

      @cur_promt = preview.move
      @infoerror_highest = infoerror_highest_level

      ready_players
    end

    def ready_players
      @current_player = player_name(@board.data.player)
      @player_turn = @board.data.player
      @player1 = player_name(:first_player)
      @player2 = player_name(:second_player)
      @cheater = player_name(session[:who_cheated])
    end

    def ready_scoreboard
      @give_up = @board.data.game_status[:give_up]
      @player_names = player_names
      @winner = @board.data.game_status[:winner]
    end
  end
end
