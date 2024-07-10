# frozen_string_literal: true

module GameHelper
    def card_path(rep)
       asset_path("cards/#{rep.downcase}.svg")
    end

    def card_name(rep)
        suit = Card.in(rep)&.suit
        "#{rep[..-2]} of #{suit}"
    end
end
