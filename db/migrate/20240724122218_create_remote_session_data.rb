# frozen_string_literal: true

class CreateRemoteSessionData < ActiveRecord::Migration[7.1]
  def change
    create_table :remote_session_data do |t|
      t.string :game_state
      t.string :preview, default: '', null: false
      t.string :who_cheated, default: '', null: false
      t.string :first_player_name
      t.string :second_player_name
      t.integer :remote_session_id

      t.timestamps
    end
  end
end
