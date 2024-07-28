# frozen_string_literal: true

# contains cruscial data about remote session
#
# (that data doesnt change, that data is stroed in RemoteSessionData)
class RemoteSession < ApplicationRecord
  has_one :remote_session_data, dependent: :destroy, class_name: 'RemoteSessionData'

  validates :name, presence: true, uniqueness: true
  validates :first_player_login, presence: true
  validates :second_player_login, presence: true
  validates :remote_session_data, presence: true

  def self.register(remote_name:, first_player_login:, second_player_login:)
    rs = RemoteSession.create(name: remote_name, first_player_login:, second_player_login:)
    rs.remote_session_data = RemoteSessionData.create(
      game_state: '', # if left empty MachiavelliBoard will handle initialiation
      first_player_name: first_player_login,
      second_player_name: second_player_login
    )
    rs.save!
  end
end
