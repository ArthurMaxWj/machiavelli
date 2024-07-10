# frozen_string_literal: true

# handles preview of Move (action-move) before its exsecuted by board
# (used by GameController)
class PreviewMove
  extend ActiveSupport::Concern

  attr_accessor :move

  def initialize(board, move_str)
    @move = move_str
    @board = board
  end

  def load_data
    # return @board.data if move.empty? # no errors for empty move

    @board.try_move(move) => {move_status:, result:}
    @board.success? ? result : @board.data
  end

  def undo_move(refresh_msgs: false)
    cmd = @move.strip

    @move = if cmd.count(' ').positive?
              cmd[..cmd.rindex(' ')] # remove last action and space
            elsif cmd.count(' ').zero?
              ''
            end
    update_data(refresh_msgs:)
  end

  def clear
    @move = ''
  end

  def update_data(refresh_msgs: true)
    result = @board.try_move(@move)
    result => {move_status:, try_mode_err_covered:, result:, error:, success:}

    if refresh_msgs
      @flash_error = error unless success
      @flash_warning = error if try_mode_err_covered && success
    end


    { success:, result: }
  end

  def try_move(cmd)
    res = nil
    if !cmd.empty? && Action.from(cmd)
      @move = "#{@move} #{cmd}".strip # append action
      update_data => { success:, result: }
      res = result
      undo_move unless success
    else
      @flash_error = "Unknown command given: #{cmd}"
    end

    res
  end

  def flash_msgs
    { error: @flash_error, warning: @flash_warning }
  end
end
