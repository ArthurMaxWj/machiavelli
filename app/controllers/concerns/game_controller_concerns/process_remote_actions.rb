# frozen_string_literal: true

module GameControllerConcerns
  # adds fucntionality responsible for remote actions on GameController
  module ProcessRemoteActions
    extend ActiveSupport::Concern


    # ACTIONS:


    def remote
      @in_remote_session = remote?
      @rname = session[:remote_name]
      @rplayer = session[:remote_player]
    end

    def remote_exit
      session[:remote_name] = nil
      session[:remote_player] = nil
      # clear session:
      RemoteSessionData.session_keys.each { |k| session[k] = nil }
      @board = nil # clear stored
      session[:game_data] = nil # clear stored
      dont_save
      go_home
    end

    def remote_connect
      rname = normalized(params[:rname])
      rplayer = normalized(params[:rplayer])
      ok = attempt_connect(rname, rplayer)

      if ok
        session[:remote_name] = rname
        session[:remote_player] = rplayer
      end
      go_home
    end

    def create_remote(name, fplayer, splayer)
      name = normalized(name)
      fplayer = normalized(fplayer)
      splayer = normalized(splayer)

      return false unless remote_creation_valid(name, fplayer, splayer)

      rs = RemoteSession.create(name:, first_player_login: fplayer, second_player_login: splayer)
      rs.remote_session_data = RemoteSessionData.create(first_player_name: fplayer, second_player_name: splayer)

      ok = rs.save!
      flash[:error] = 'Remote error: unidentified' unless ok
      ok
    end

    def remote_create
      rname = params[:rname]
      rfplayer = params[:rfplayer]
      rsplayer = params[:rsplayer]
      if create_remote(rname, rfplayer, rsplayer)
        session[:remote_name] = rname
        session[:remote_player] = rfplayer
      end

      go_home
    end

    def wait_for_turn
      go_home unless await_turn?(session[:remote_player])
      @simulation_enabled = remote_session.name.end_with?('--simulate-opponent')

      ready_front_waiting
    end

    def simulate_opponent
      login_attr = login_attr_of(order: @board.data.player)
      session[:remote_player] = remote_session.read_attribute(login_attr)

      go_home
    end

    # OPTIMIZE: Use ActionCable/WebSockets instead (also does current hosting support?)
    # used by AJAX to signal turn change (switches control from one player to another)
    def whose_turn
      render json: { player_turn: @board.data.player }
    end


    private


    # HELPERS:


    def attempt_connect(rname, rplayer)
      rs = RemoteSession.find_by(name: rname)

      ok = rs.present? ? (rs.first_player_login == rplayer || rs.second_player_login == rplayer) : false
      flash[:error] = 'Connection failed: check name and login' unless ok
      ok
    end

    def remote_creation_valid(name, fplayer, splayer)
      if !syntax_ok?([name, fplayer, splayer])
        flash[:error] = "Remote error: name/login must match pattern [a-z0-9_\-]+ (only letters numbers - and _)"
      elsif fplayer == splayer
        flash[:error] = 'Remote error: player logins cant be the same'
      elsif RemoteSession.find_by(name:)
        flash[:error] = 'Remote error: Name is taken, use different name'
      else
        return true
      end

      false
    end

    def syntax_ok?(names)
      names.all? do |str|
        str.match(/\A[a-z0-9_-]+\Z/)
      end
    end

    def normalized(name)
      name.strip.downcase
    end
  end
end
