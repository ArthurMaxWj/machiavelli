# frozen_string_literal: true

# contains dynamic data about remote session such as game data and non-remote session
class RemoteSessionData < ApplicationRecord
  self.table_name = 'remote_session_data'
  belongs_to :remote_session

  # validates :game_state, presence: true
  validates :first_player_name, presence: true
  validates :second_player_name, presence: true
  validates :remote_session_id, presence: true

  def game_state_as_game_data
    GameData.from_json(game_state)
  end

  def prepared?
    game_state.present?
  end

  def self.accepted_key?(key)
    %i[game_state preview first_player_name second_player_name who_cheated].include?(key)
  end

  def self.session_keys
    %i[game_state preview first_player_name second_player_name who_cheated]
  end
end
