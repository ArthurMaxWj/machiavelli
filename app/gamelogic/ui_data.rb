# frozen_string_literal: true

UiData = Struct.new(:affected_cards, :affecting_action, :actions, :advance_move) do
  def deep_duplicate
    UiData.new(affected_cards.dup, affecting_action.dup, actions.dup, advance_move)
  end

  def to_json(*_args)
    to_h.to_json
  end
end

def UiData.fresh
  UiData.new(affected_cards: [], affecting_action: '', actions: [], advance_move: true)
end

def UiData.props
  %i[affected_cards affecting_action actions advance_move]
end

def UiData.from_h(a_hash)
  h = a_hash.transform_keys(&:to_sym)

  return nil unless h.keys == UiData.props

  UiData.new(**h)
end
