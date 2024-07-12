# frozen_string_literal: true

# require_relative '../../../extra_classes/game_controller_extra_classes/preview_move'


module GameControllerConcerns
  # methods shared with other moduls being part fo GameController
  module CommonGameBack
    extend ActiveSupport::Concern

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
      @preview_move ||= GameControllerExtraClasses::PreviewMove.new(@board, session[:preview].presence || '')

      @preview_move
    end
  end
end
