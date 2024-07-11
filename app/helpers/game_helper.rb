# frozen_string_literal: true

# helps with expanding commands and card names/paths
module GameHelper
  def card_path(rep)
    asset_path("cards/#{rep.downcase}.svg")
  end

  def card_name(rep)
    suit = Card.in(rep)&.suit
    "#{rep[..-2]} of #{suit}"
  end

  def command_list
    %i[n m p b]
  end

  def expand_command(cmd)
    {
      n: '[n] New combination (3, 0, 0)',
      m: '[m] Move card (1, 1, 0)',
      p: '[p] Put card (0, 0,1)',
      b: '[b] Break combination (0, 1, 0)'
    }[cmd]
  end
end
