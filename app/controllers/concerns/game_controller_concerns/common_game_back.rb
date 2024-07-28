# frozen_string_literal: true

module GameControllerConcerns
  # methods shared with other moduls being part fo GameController
  module CommonGameBack
    extend ActiveSupport::Concern

    def do_save
      @save_data_after = true
    end

    def dont_save
      @save_data_after = false
    end

    def go_home
      redirect_to action: 'index'
      true # for chaining return
    end

    def go_scoreboard
      redirect_to action: 'scoreboard'
      true # for chaining return
    end

    def go_wait_for_turn
      redirect_to action: 'wait_for_turn'
      true # for chaining return
    end

    def s(key, val)
      remote_session_data.write_attribute(key, val) if remote? && RemoteSessionData.accepted_key?(key)
      session[key] = val
    end

    def sg(key)
      return remote_session_data[key] if remote?

      session[key]
    end

    def f(key, val)
      flash[key] = val
    end

    def player_name(player)
      case player
      when :first_player
        sg(:first_player_name).presence || 'Alex'
      when :second_player
        sg(:second_player_name).presence || 'Max'
      else
        '<unknown player>'
      end
    end

    def other_player(player)
      player == :first_player ? :second_player : :first_player
    end

    def player_names
      { first_player: player_name(:first_player), second_player: player_name(:second_player) }
    end

    def preview
      @preview_move ||= GameControllerExtraClasses::PreviewMove.new(@board, sg(:preview).presence || '')

      @preview_move
    end
  end
end
