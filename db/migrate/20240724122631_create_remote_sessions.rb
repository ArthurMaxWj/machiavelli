# frozen_string_literal: true

class CreateRemoteSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :remote_sessions do |t|
      t.string :name
      t.string :first_player_login
      t.string :second_player_login
      t.datetime :last_used, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end

    add_index :remote_sessions, :name, unique: true
  end
end
