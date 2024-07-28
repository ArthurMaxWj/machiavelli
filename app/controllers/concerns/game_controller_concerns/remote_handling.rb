# frozen_string_literal: true

module GameControllerConcerns
  # methods shared with other moduls being part fo GameController
  module RemoteHandling
    extend ActiveSupport::Concern

    def remote_sync
      return false unless check_for_remote

      return false unless
        @remote_session.first_player_login == session[:remote_player] ||
        @remote_session.second_player_login == session[:remote_player]


      @remote_session_data = @remote_session.remote_session_data

      true
    end

    def check_for_remote
      return false unless session[:remote_name].present? && session[:remote_player].present?

      @remote_session = RemoteSession.includes(:remote_session_data).find_by(name: session[:remote_name])
      @remote_session ? true : false
    end

    def remote?
      @is_remote
    end

    def await_turn?(rplayer)
      if remote? && @remote_session_data.prepared?
        turn_of_player = @remote_session_data.game_state_as_game_data.player
        our_player = order_of(login: rplayer)

        return turn_of_player != our_player
      end

      false
    end

    def remote_session_data
      @remote_session_data
    end

    def remote_session
      @remote_session
    end

    def remote_init
      @is_remote = remote_sync
    end

    def remote_save
      return false unless @remote_session_data.valid? && @remote_session.valid?

      @remote_session_data.save!
      @remote_session.save!

      true
    end

    def load_remote_session_data
      RemoteSessionData.session_keys.each do |k|
        session[k] = @remote_session_data.read_attribute(k)
      end
    end

    def login_of(order:)
      login_attr = login_attr_of(order:)
      remote_session.read_attribute(login_attr)
    end

    def login_attr_of(order:)
      order == :first_player ? :first_player_login : :second_player_login
    end

    def order_of(login:)
      @remote_session.first_player_login == login ? :first_player : :second_player
    end
  end
end
