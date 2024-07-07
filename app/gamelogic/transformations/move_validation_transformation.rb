# frozen_string_literal: true

require_relative '.\transformation'
require_relative '..\move'

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
    #     binding.break if move_str == 'p.-3:0-4' && BN == ['hi']


    @success = work_with_move(move_str)
  end

  def work_with_move(move_str)
    deck = hdata.player_decks[hdata.player]
    Move.from(move_str, hdata.table, deck) => {ok:, value:}
    return e("Incorrect action: '#{value}'") unless ok
    # binding.break if move_str == 'p.-3:0-4' && BN == ['hi']

    exec_move(value) => {success:, resultant_data:}
    return false unless success

    check_table(resultant_data[:table]) => {ok:, error:}
    @try_mode_err_covered = !ok
    e(error) # unless @try_mode

    save_hdata(resultant_data) if success && (ok || @try_mode)
    success && ok
  end

  def exec_move(value)
    check_move_effects(value) => { error:, success:, table:, rdat:}

    s = success ? true : e(error)

    { success: s, resultant_data: rdat }
  end

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
