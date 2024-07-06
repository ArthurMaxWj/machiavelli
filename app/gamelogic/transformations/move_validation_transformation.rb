# frozen_string_literal: true

require_relative '.\transformation'
require_relative '..\move'
# require 'byebug'

# adds control commands to MAchiavelliBoard
class MoveValidationTransformation < Transformation
  attr_reader :try_mode, :try_mode_err_covered

  def initialize
    super

    @try_mode = false
    @try_mode_err_covered = false
  end

  def handle(args)
    raise ArgumentError, 'At least one argument required' if args.empty?

    cmdstr, @try_mode = args
    @try_mode_err_covered = false

    # unless true #cmdstr == "n.-0,.-1,.-2:_"
    # @bye = true
    # byebug
    # else
    # @bye = false
    # end

    handle_move_validation(cmdstr)
  end

  def handled?
    @handled
  end

  def success?
    @success
  end

  def update_after(_new_data)
    @data.move_status = { ok: success, error: errors.first }
  end

  private

  def handle_move_validation(move_str)
    if move_str.split(' ').empty?
      @handled = false
      return false
    end

    @handled = true

    @success = work_with_move(move_str)
  end

  def work_with_move(move_str)
    deck = hdata.player_decks[hdata.player]
    Move.from(move_str, hdata.table, deck) => {ok:, value:}
    return e("Incorrect action: '#{value}'") unless ok

    exec_move(value) => {success:, resultant_data:}

    check_table(resultant_data[:table]) => {ok:, error:}
    @try_mode_err_covered = !ok
    e(error) # unless @try_mode

    save_hdata(resultant_data) if success && (ok || @try_mode)
    success
  end

  def exec_move(value)
    check_move_effects(value) => { error:, success:, table:, rdat:}
    # return e(error) unless success

    # s = success ? check_table(table) : e(error)
    s = if success
          # @try_mode_err_covered = !check_table(table)

          true
        else
          e(error)
        end

    { success: s, resultant_data: rdat }
  end

  # takes block and backups data, if block returns true does nothing,
  # else performs checks and uses backup data if needed
  # def safe_move
  # hdata.deep_duplicate
  # hdata.table.reduce([]) { |a, b| a + b.dup }
  # hdata.player_decks.map(&:dup).to_h

  # successful = yield

  # return false unless successful

  # true
  # end

  def check_all_correct(table)
    table.map { |cards| Combination.new(cards) }.each do |comb|
      r = { ok: comb.valid?, error: comb.error }

      return r unless r[:ok]
    end

    { ok: true, error: nil }
  end

  def check_move_effects(value)
    rdat = value.run
    rdat => {
          success:, error:,
          table:, deck:,
          affected_cards:, affecting_action:,
          actions:
        }

    { error:, success:, table:, rdat: }
  end

  # move was succesful, now check if combinations are valid
  def check_table(table)
    # hdata.move_status = check_all_correct(table)
    # hdata.move_status => {ok:, error:}
    check_all_correct(table)
  end

  def save_hdata(resulting_data)
    hdata.uidata.affected_cards = resulting_data[:affected_cards]
    hdata.uidata.affecting_action = resulting_data[:affecting_action]
    hdata.uidata.actions = resulting_data[:actions]
    hdata.table = resulting_data[:table]
    hdata.player_decks[hdata.player] = resulting_data[:deck]

    true
  end
end
