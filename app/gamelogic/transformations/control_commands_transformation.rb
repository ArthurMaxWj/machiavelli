# frozen_string_literal: true

require_relative '.\transformation'

# adds control commands to MAchiavelliBoard
class ControlCommandsTransformation < Transformation
  def handle(args)
    raise ArgumentError, 'Exactly one argument required' unless args.size == 1

    handle_control_commands(args.first)
  end

  def handled?
    !@success.nil?
  end

  def success?
    !!@success
  end

  def update_after(_new_data)
    hdata.move_status = { ok: success, error: errors.first }
  end


  private

  def handle_control_commands(move_str)
    @success = case move_str
               when 'g'
                 give_up
               when 'd'
                 ccmd_draw
               when 's'
                 ccmd_skip
               end
  end

  def ccmd_draw
    if hdata.drawboard.cards.empty?
      e('No more cards left to draw, use s (skip)')
    else
      hdata.player_decks[hdata.player] += [hdata.drawboard.draw_card]
      fine
    end
  end

  def give_up
    if hdata.drawboard.cards.empty?
      hdata.game_status = { finished: true, give_up: true, winner: hdata.other_player }
      fine
    else
      e('Cards still left to draw, use d (draw)')
    end
  end

  def ccmd_skip
    return e('Cards still left to draw, use d (draw)') unless	hdata.drawboard.cards.empty?

    hdata.player_skips[hdata.player] += 1
    fine
  end
end
