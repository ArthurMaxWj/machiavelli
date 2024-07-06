# frozen_string_literal: true

# simple struct for storing one action (move, put, new, etc.)
Action = Struct.new(:name, :origin, :destination) do
  def self.action_types
    %i[draw_card move_card split_combination put_card put_combination new_combination].freeze
  end

  def action!(str)
    Action.from(str) or raise 'Incorrect data'
  end

  def action_shorts
    self.class.action_shorts
  end

  def self.action_shorts
    { 'm' => :move_card, 'p' => :put_card, 'n' => :new_combination, 's' => :split_combination }.freeze
  end

  def self.from(str)
    Action.new.from(str)
  end

  def from(str)
    str = perform_substitiutions(str)
    return nil if str.size < 8

    tod =  type_orig_dest(str)
    return nil unless tod

    type, os, d = tod


    type_valid = action_shorts.key?(type)
    dest_valid = !d.nil?
    all_orig_valid = os.none?(&:nil?)
    return nil unless type_valid && dest_valid && all_orig_valid

    Action.new(action_shorts[type], os, d)
  end

  def perform_substitiutions(str)
    str = str.sub('.', '0') while str.include?('.')
    # str.sub!('~', '0-') while str.include?('~')
    str = str.sub('_', '0-0') while str.include?('_')
    str
  end

  def type_orig_dest(str)
    type = str[0]
    os, d = str[1..].split(':')
    return nil if d.nil? || os.nil?

    # return nil if [d, os].any?(&:empty?) # could be nil or ""
    os = os.split(',')

    d = try_num_pair(d)
    os = os.map { |o| try_num_pair(o) }

    [type, os, d]
  end

  def try_num_pair(str)
    pair = str.split('-')
    return nil unless pair.size == 2

    a, b = pair
    return nil unless a == a.to_i.to_s && b == b.to_i.to_s

    [a.to_i, b.to_i]
  end
end

Action::ACTION_TYPES = Action.action_types
Action::ACTION_SHORTS = Action.action_shorts
