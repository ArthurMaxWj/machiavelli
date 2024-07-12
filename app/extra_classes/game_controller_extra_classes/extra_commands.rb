# frozen_string_literal: true

module GameControllerExtraClasses
  # commands related to transformations used by GameController
  class ExtraCommands
    include TransformationHandler
    attr_accessor :data, :ui

    attr_accessor :helper_out, :who_cheated, :success, :error


    def initialize(data)
      @data = data.deep_duplicate
    end

    def cmd(cmd, args)
      kind = CheatCommandsTransformation::CHEAT_CMDS.include?("%#{cmd}") ? :cheat : :helper
      kind == :cheat ? nil : @ui = ConsoleUi.new(:o, store: true)

      kind == :cheat ? cheat("%#{cmd}", args) : helper("&#{cmd}", args)
    end

    def cheat(cmd, args)
      if CheatCommandsTransformation::CHEAT_CMDS.include?(cmd)
        @success = process_cheat(cmd, args)
      else
        @error = 'Unknown cheat/helper command'
      end

      { success:, error:, who_cheated:, data:, helper_out: nil }
    end

    def helper(cmd, args)
      if HelperCommandsTransformation::CMD_LIST.include?(cmd)
        @success = process_helper(cmd, args)
      else
        @error = 'Unknown cheat/helper command'
      end

      { success:, error:, helper_out:, data:, who_cheated: nil }
    end

    def transformation_list
      @tlist ||= {
        helper_commands: HelperCommandsTransformation.new,
        cheat_commands: CheatCommandsTransformation.new
      }

      @tlist
    end


    private

    def process_cheat(cmd, args)
      cheat_move("#{cmd} #{args}") => {ok:, error:}
      if ok
        @who_cheated = @data.player
        true
      else
        @error = error
        false
      end
    end

    def process_helper(cmd, args)
      helper_move("#{cmd} #{args}") => {ok:, error:}
      if ok
        @helper_out = @ui.stored.join('')
        true
      else
        @error = error
        false
      end
    end

    def cheat_move(move_str)
      e('Not a cheat command') unless handle(:cheat_commands, move_str)

      @data.move_status
    end

    def helper_move(move_str)
      e('Not a helper command') unless handle(:helper_commands, move_str)

      @data.move_status
    end
  end
end
