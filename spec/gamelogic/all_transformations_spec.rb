# frozen_string_literal: true

# spec/all_transformations_spec.rb
require './app/gamelogic/machiavelli_board'
require './app/gamelogic/transformations/helper_commands_transformation'
require './app/gamelogic/transformations/cheat_commands_transformation'

# describes all subclasses of Transformation
describe Transformations do
  describe Transformations::ControlCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { described_class.new }

    context 'when wrong command given' do
      let(:cmd) { 'wrong' }
      let(:old) { board.data.deep_duplicate }

      it 'does NOT affect data' do
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(old.wiped).to eql(new_data.deep_duplicate.wiped)
      end

      it 'is NOT handled' do
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(handled).to be false
      end
    end


    context 'when correct d/draw_card command given' do
      let(:cmd) { 'd' }
      let(:old) { board.data.deep_duplicate }

      it 'affects data' do
        d = mod(transf, old, cmd)


        expect(old.wiped).not_to eql(d.wiped)
      end

      it 'affects data drawboard' do
        d = mod(transf, old, cmd)

        expect(old.drawboard).not_to eql(d.drawboard)
      end

      it 'data not nil' do
        d = mod(transf, old, cmd)

        expect(d).not_to be_nil
      end

      it 'affects drawboard and deck properly' do
        d = mod(transf, old, cmd)

        expect(old.drawboard.size).to eql(d.drawboard.size + 1)
      end
    end


    context 'when correct s/skip_turn command given' do
      let(:cmd) { 's' }
      let(:old) { board.data.deep_duplicate }

      before { board.data.drawboard.cards = [] }

      it 'affects data' do
        d = mod(transf, old, cmd)

        expect(old.wiped).not_to eql(d.wiped)
      end

      it 'affects player_skips' do
        d = mod(transf, old, cmd)


        expect(old.player_skips).not_to eql(d.player_skips)
      end

      it 'affects player_skips properly' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)

        expect(old.player_skips[old.player]).to eql(d.player_skips[d.player] - 1)
      end
    end


    context 'when correct g/given_up command given' do
      let(:cmd) { 'g' }
      let(:old) { board.data.deep_duplicate }

      before { board.data.drawboard.cards = [] }

      it 'affects game status' do
        d = mod(transf, old, cmd)

        expect(old.wiped).not_to eql(d.wiped)
      end

      it 'affects data properly' do
        d = mod(transf, old, cmd)

        is_changed = old.wiped != d.wiped
        is_not_nil = !d.nil?
        expect(is_changed && is_not_nil).to be true
      end

      it 'affects game status' do
        d = mod(transf, old, cmd)

        expect(old.game_status).not_to eql(d.game_status)
      end

      it 'affects game_status properly' do
        d = mod(transf, old, cmd)

        expect(d.game_status).to eql({ finished: true, give_up: true, winner: d.other_player })
      end
    end

    context 'when NOT correct d/draw_card command used on NON-empty drawboard' do
      let(:cmd) { 'd' }
      let(:old) { board.data.deep_duplicate }

      before { board.data.drawboard.cards = [] }

      it 'does NOT affect data' do
        modify(transf, old, cmd) => {new_data:, handled:, success:}

        expect(old.wiped).to eql(new_data.wiped)
      end

      it 'is handled' do
        modify(transf, old, cmd) => {new_data:, handled:, success:}

        expect(handled).to be true
      end

      it 'is NOT success' do
        modify(transf, old, cmd) => {new_data:, handled:, success:}

        expect(success).to be false
      end

      it 'reports correct error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(errors.first).to eql('No more cards left to draw, use s (skip)')
      end
    end

    context 'when NOT correct s/skip_turn command used on NON-empty drawboard' do
      let(:cmd) { 's' }
      let(:old) { board.data.deep_duplicate }

      it 'is handled' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(handled).to be true
      end

      it 'is NOT success' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(success).to be false
      end

      it 'reports correct error' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(errors.first).to eql('Cards still left to draw, use d (draw)')
      end
    end


    context 'when NOT correct g/given_up command given' do
      let(:cmd) { 'g' }
      let(:old) { board.data.deep_duplicate }

      it 'is handled' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(handled).to be true
      end

      it 'is NOT success' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(success).to be false
      end

      it 'reports correct error' do
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(errors.first).to eql('Cards still left to draw, use d (draw)')
      end
    end
  end

  describe Transformations::HelperCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { described_class.new }



    context 'when wrong command given' do
      let(:cmd) { 'wrong' }
      let(:old) { board.data.deep_duplicate }

      it 'does NOT affect data' do
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(old.wiped).to eql(new_data.wiped)
      end

      it 'is handled' do
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(handled).to be false
      end
    end

    context 'when NOT correct &comb used with no args' do
      let(:cmd) { '&comb' }
      let(:old) { board.data.deep_duplicate }

      it 'is hanfled' do
        modify(transf, old, cmd) => {handled:, new_data:, success:, errors:}

        expect(handled).to be true
      end


      it 'is NOT success' do
        modify(transf, old, cmd) => {handled:, new_data:, success:, errors:}

        expect(success).to be false
      end

      it 'does NOT affect data' do
        modify(transf, old, cmd) => {handled:, new_data:, success:, errors:}

        expect(old.wiped).to eql(new_data.wiped)
      end

      it 'reports proper error' do
        modify(transf, old, cmd) => {handled:, new_data:, success:, errors:}

        expect(errors.first.include?('Not a number')).to be true
      end
    end


    context 'when any correct command used' do
      let(:all_cmds) { ['...', '&comb 0', '&deck'] }
      let(:old) { board.data.deep_duplicate }
      let(:res) do
        all_cmds.map do |cmd|
          modify(transf, old, cmd) => {handled:, new_data:, success:}

          [handled, { old:, new_data:, success: }]
        end
      end

      it 'does NOT affect data' do
        all_same = res.map(&:last).all? do |dat|
          dat[:old].wiped == dat[:new_data].wiped
        end

        expect(all_same).to be true
      end

      it 'are all handled' do
        all_handled = res.map(&:first).all? { |handled| handled }

        expect(all_handled).to be true
      end
    end
  end

  describe Transformations::CheatCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { described_class.new }
    let(:old) { board.data.deep_duplicate }

    context 'when correct %cget/%cheat.get command given' do
      let(:cards) { '2d 10s 6h' }

      it 'affects data' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}


          expect(old.wiped).not_to eql(new_data.wiped)
        end
      end

      it 'does affect player_decks' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}


          expect(old.player_decks).not_to eql(new_data.player_decks)
        end
      end

      it 'is successs' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}

          expect(success).to be true
        end
      end

      it 'is handled' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}

          expect(handled).to be true
        end
      end


      it 'alters player_decks properly but not drawboard' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}
          cards_added = cards.split(' ').map { |c| Card.in(c) }

          expect(new_data.player_decks[new_data.player]).to eql(old.player_decks[old.player] + cards_added)
        end
      end

      it 'does NOT alter drawboard' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}

          expect(old.drawboard == new_data.drawboard).to be true
        end
      end

      it 'does NOT alter drawboard size' do
        ['%cget', '%cheat.get'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}

          expect(old.drawboard.cards.size == new_data.drawboard.cards.size).to be true
        end
      end
    end

    context 'when correct %cdraw/%cheat.draw command given' do
      let(:cards) { '2d 10s 6h' }
      let(:old) { board.data.deep_duplicate }

      it 'affects data' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          expect(old.wiped).not_to eql(new_data.wiped)
        end
      end

      it 'affects data player_decks' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          expect(old.player_decks).not_to eql(new_data.player_decks)
        end
      end

      it 'affects data drawboard' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          expect(old.drawboard).not_to eql(new_data.drawboard)
        end
      end

      it 'is handled' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}

          expect(handled).to be true
        end
      end

      it 'is success' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          expect(success).to be true
        end
      end


      it 'alters player_decks properly' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}
          cards_added = cards.split(' ').map { |c| Card.in(c) }

          added_to_deck = (new_data.player_decks[new_data.player] == old.player_decks[old.player] + cards_added)
          expect(added_to_deck).to be true
        end
      end

      it 'alters drawboard properly' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          modify(transf, old, "#{cmd} #{cards}") => {new_data:, handled:, success:}
          cards_added = cards.split(' ').map { |c| Card.in(c) }

          removed_from_drawboard = new_data.drawboard.cards.size == (old.drawboard.cards.size - cards_added.size)
          expect(removed_from_drawboard).to be true
        end
      end
    end

    context 'when NOT correct %cdraw/%cheat.draw command used' do
      context 'with empty argline' do
        let(:cards) { '' }
        let(:old) { board.data.deep_duplicate }

        it 'is NOT success' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(success).to be false
          end
        end

        it 'is NOT handled' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(handled).to be true
          end
        end

        it 'reports proper error' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(errors.first).to eql('No cards given')
          end
        end
      end

      context 'with argline containing worng card' do
        let(:cards) { '10s 1000d 10x' }

        it 'is handled' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(handled).to be true
          end
        end

        it 'is NOT success' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(success).to be false
          end
        end

        it 'reports proper error' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first.include?('No such card:')).to be true
          end
        end
      end
    end


    context 'when NOT correct %cget/%cheat.get command used' do
      context 'with empty argline' do
        let(:cards) { '' }
        let(:old) { board.data.deep_duplicate }

        it 'is handled' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(handled).to be true
          end
        end

        it 'is NOT success' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(success).to be false
          end
        end

        it 'reports error' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first).to eql('No cards given')
          end
        end
      end

      context 'with argline containing worng card' do
        let(:cards) { '10s 1000d 10x' }
        let(:old) { board.data.deep_duplicate }

        it 'is handled' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(handled).to be true
          end
        end

        it 'is NOT success' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}

            expect(success).to be false
          end
        end

        it 'reports error' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first.include?('No such card:')).to be true
          end
        end
      end
    end
  end
end

def modify(transformation, dat, cmd_arg, progress_move_optional: false)
  # for MoveValidationTransformation to turn off error for not gettign rid fo any cards
  return transformation.process(dat.deep_duplicate, [cmd_arg, false, true], console) if progress_move_optional

  transformation.process(dat.deep_duplicate, [cmd_arg], console)
end

def mod(transformation, data, args)
  modify(transformation, data.deep_duplicate, args) => {new_data:, handled:, success:}
  handled && success ? new_data : nil
end

def mod!(transformation, data, args)
  modify(transformation, data.deep_duplicate, args) => {new_data:}

  new_data
end

def console
  ConsoleUi.new(:none) # no input or output allowed
end
