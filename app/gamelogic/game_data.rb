# frozen_string_literal: true

require 'json'
# require 'byebug'
require_relative 'drawboard'
require_relative 'uidata'

GD_PROPERTIES = %i[game_status move_status
                   player drawboard player_decks player_skips table uidata].freeze

# data of singular game (only GameBoard, no interface included)
GameData = Struct.new(*GD_PROPERTIES) do
  def init
    self.game_status = { finished: false, give_up: false, winner: :vvv }
    self.move_status = { ok: false, error: 'Neiter player moved yet' }

    self.player = players.first
    self.drawboard = Drawboard.fresh
    gen_init_data => {player_decks:, player_skips:}
    self.player_decks = player_decks
    self.player_skips = player_skips
    self.table = []
    self.uidata = UIData.fresh
    self
  end

  def init_with(**props)
    init

    props.each do |p, val|
      self[p] = val
    end

    self
  end

  def self.fresh
    GameData.new.init
  end

  def gen_init_data
    {
      player_decks: players.map do |p|
                      [p, []]
                    end.to_h,
      player_skips: players.map { |p| [p, 0] }.to_h
    }
  end

  def reset
    init
  end

  def self.players
    %i[first_player second_player].freeze
  end

  def players
    %i[first_player second_player].freeze
  end

  def other_player
    player == :first_player ? :second_player : :first_player
  end

  def switch_player
    self.player = other_player
  end

  def size
    table.size
  end

  def all_cards
    table.map(&:dup)
  end

  def get(comb_num, card_num)
    table[comb_num][card_num]
  end

  def get_comb(comb_num)
    table[comb_num].dup
  end

  # def simple_deep_duplicate
  # copied = self.dup

  # copied.game_status = game_status.dup
  # copied.move_status = move_status.dup
  # copied.drawboard = drawboard.dup
  # copied.table = table.dup
  # copied.player_decks = player_decks.to_a.each(&:dup).to_h
  # copied.player_skips = player_skips.to_a.each(&:dup).to_h
  # copied.uidata = uidata.deep_duplicate

  # copied
  # end

  def deep_duplicate
    to_dup = %i[game_status move_status]
    copied = dup

    to_dup.each do |prop|
      copied[prop] = self[prop].dup
    end

    copied.table = table.map(&:dup)



    complex_dup(copied)
  end

  # used for thests to remove data unnecessary for comparisions
  def wiped
    w = deep_duplicate
    w.move_status = {}
    w.drawboard.order
    w.uidata = UIData.fresh
    w
  end

  def to_json(*_args)
    to_h.to_json
  end

  # same as to_json but works in Rails (active support uses this method instead)
  def as_json(*_args)
    to_h.as_json
  end

  def self.from_json(json_str)
    GameDataFromJSON.new(json_str).convert => {success:, result:}
    success ? result : nil
  end

  def now_deck
    player_decks[player]
  end

  private

  def complex_dup(copied)
    copy_substructures(copy_hashes(copied))
  end

  def copy_hashes(copied)
    copied.player_decks = player_decks.transform_values(&:dup)
    copied.player_skips = player_skips.transform_values(&:dup)
    copied
  end

  def copy_substructures(copied)
    copied.uidata = uidata.deep_duplicate
    copied.drawboard = drawboard.deep_duplicate
    copied
  end
end


GameData::PROPERTIES = GD_PROPERTIES

# used by GameData to deserialize itself from JSON
class GameDataFromJSON
  attr_reader :error

  def initialize(json_str)
    @h = JSON.parse(json_str)
  end

  def convert
    @success = from_h

    { result: GameData.fresh.init_with(**@h), success: @success }
  end

  private

  def from_h
    [keys_check, values_check, cards_check, substructures_check].all? do |v|
      v
    end
  end

  def keys_check
    @h = @h.transform_keys(&:to_sym)
    return e('Wrong keys') unless @h.keys == GD_PROPERTIES

    %i[player_decks player_skips].each do |k|
      @h[k] = @h[k].transform_keys(&:to_sym)
      return e("Wrong #{k} keys") unless @h[k].keys == %i[first_player second_player]
    end

    true
  end

  def values_check
    [player_ok, move_status_ok, game_status_ok, winner_ok].all?
  end

  def player_ok
    p = @h[:player] = @h[:player].to_sym
    %i[first_player second_player].include?(p) ? true : e('Wrong :player value')
  end

  def move_status_ok
    @h[:move_status] = @h[:move_status].transform_keys(&:to_sym)
    @h[:game_status].keys.map { |k| %i[finished give_up winner].include?(k) } ? true : e('Wrong :game_status value')
  end

  def game_status_ok
    @h[:game_status] = @h[:game_status].transform_keys(&:to_sym)
    @h[:move_status].keys == %i[ok error] ? true : e('Wrong :move_status value')
  end

  def winner_ok
    w = @h[:game_status][:winner] = @h[:game_status][:winner].to_sym
    %i[vvv first_player second_player].include?(w) ? true : e('Wrong :game_status[:winner] value')
  end

  def cards_check
    [pdcards_ok, tcards_ok].all?
  end

  def pdcards_ok
    @h[:player_decks] = @h[:player_decks].transform_values do |v|
      v.map { |c| Card.in(c) }
    end
    any_cards_nil = @h[:player_decks].any? do |dc|
      dc.any?(&:nil?)
    end

    any_cards_nil ? e('Wrong cards in :player_decks') : true
  end

  def tcards_ok
    @h[:table] = @h[:table].map { |v| v.map { |c| Card.in(c) } }

    @h[:player_decks].any?(&:nil?) ? e('Wrong cards in :table') : true
  end

  def substructures_check
    @h[:drawboard] = Drawboard.from_h(@h[:drawboard].to_h)
    @h[:uidata] = UIData.from_h(@h[:uidata].to_h)
    return e('Wrong :drawboard/:uidata') if @h[:drawboard].nil? || @h[:uidata].nil?

    true
  end

  def e(err)
    @error = err
    false
  end
end


# a = GameData.fresh
# a[:player_decks][:first_player] = [Card.in('10D'), Card.in('5S'), Card.in('8H')]
# c = GameDataFromJSON.new(a.to_json); c.convert => {success:, result:}
# puts a.to_json
# puts
# puts "Result: #{result}"
# puts "Error: #{c.error}"
# puts "Success: #{success}"
# puts a == result
