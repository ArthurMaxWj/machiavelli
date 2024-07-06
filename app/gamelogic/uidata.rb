# frozen_string_literal: true

UIData = Struct.new(:affected_cards, :affecting_action, :actions, :advance_move) do
  def deep_duplicate
    UIData.new(affected_cards.dup, affecting_action.dup, actions.dup, advance_move)
  end

  def to_json(*_args)
    to_h.to_json
  end
end

def UIData.fresh
  UIData.new(affected_cards: [], affecting_action: '', actions: [], advance_move: true)
end

def UIData.props
  %i[affected_cards affecting_action actions advance_move]
end

def UIData.from_h(a_hash)
  h = a_hash.transform_keys(&:to_sym)

  return nil unless h.keys == UIData.props

  UIData.new(**h)
end
