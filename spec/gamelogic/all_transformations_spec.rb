# frozen_string_literal: true

# spec/all_transformations_spec.rb
require './app/gamelogic/machiavelli_board'
require './app/gamelogic/transformations/helper_commands_transformation'
require './app/gamelogic/transformations/cheat_commands_transformation'

# describes all subclasses of Transformation
describe 'all transformations' do
  describe Transformations::ControlCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { Transformations::ControlCommandsTransformation.new }

    context 'when wrong command given' do
      let(:cmd) { 'wrong' }
      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(handled).to be false
        expect(old.wiped).to be_eql(new_data.deep_duplicate.wiped)
      end
    end


    context 'when correct d/draw_card command given' do
      let(:cmd) { 'd' }
      it 'affects data' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)


        expect(old.wiped).to_not be_eql(d.wiped)
        expect(old.drawboard).to_not be_eql(d.drawboard)
        expect(d).to_not be_nil
      end

      it 'affects drawboard and deck properly' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)

        expect(old.drawboard).to_not be_eql(d.drawboard)
        expect(old.drawboard.size).to be_eql(d.drawboard.size + 1)
        expect(d).to_not be_nil
      end
    end


    context 'when correct s/skip_turn command given' do
      let(:cmd) { 's' }
      before { board.data.drawboard.cards = [] }

      it 'affects data' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)


        expect(old.wiped).to_not be_eql(d.wiped)
        expect(old.player_skips).to_not be_eql(d.player_skips)
        expect(d).to_not be_nil
      end

      it 'affects player_skips properly' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)

        expect(old.player_skips).to_not be_eql(d.player_skips)
        expect(old.player_skips[old.player]).to be_eql(d.player_skips[d.player] - 1)
      end
    end


    context 'when correct g/given_up command given' do
      let(:cmd) { 'g' }
      before { board.data.drawboard.cards = [] }

      it 'affects data' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)

        expect(old.wiped).to_not be_eql(d.wiped)
        expect(old.game_status).to_not be_eql(d.game_status)
        expect(d).to_not be_nil
      end

      it 'affects drawboard and deck properly' do
        old = board.data.deep_duplicate
        d = mod(transf, old, cmd)

        expect(d.game_status).to be_eql({ finished: true, give_up: true, winner: d.other_player })
      end
    end

    context 'when NOT correct d/draw_card command used on NON-empty drawboard' do
      let(:cmd) { 'd' }
      before { board.data.drawboard.cards = [] }

      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {new_data:, handled:, success:}

        expect(old.wiped).to be_eql(new_data.wiped)
        expect(handled).to be true
        expect(success).to be false
      end

      it 'reports correct error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(handled).to be true
        expect(success).to be false
        expect(errors.first).to be_eql('No more cards left to draw, use s (skip)')
      end
    end

    context 'when NOT correct s/skip_turn command used on NON-empty drawboard' do
      let(:cmd) { 's' }

      it 'reports correct error' do
        old = board.data.deep_duplicate

        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(handled).to be true
        expect(success).to be false
        expect(errors.first).to be_eql('Cards still left to draw, use d (draw)')
      end
    end


    context 'when NOT correct g/given_up command given' do
      let(:cmd) { 'g' }

      it 'reports correct error' do
        old = board.data.deep_duplicate

        modify(transf, old, cmd) => {handled:, errors:, success:}

        expect(handled).to be true
        expect(success).to be false
        expect(errors.first).to be_eql('Cards still left to draw, use d (draw)')
      end
    end
  end

  describe Transformations::HelperCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { Transformations::HelperCommandsTransformation.new }



    context 'when wrong command given' do
      let(:cmd) { 'wrong' }
      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {handled:, new_data:}

        expect(old.wiped).to be_eql(new_data.wiped)
        expect(handled).to be false
      end
    end

    context 'when NOT correct &comb used with no args' do
      let(:cmd) { '&comb' }
      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        modify(transf, old, cmd) => {handled:, new_data:, success:, errors:}

        # expect(old.wiped).to be_eql(new_data.wiped)
        expect(errors.first.include?('Not a number')).to be true
        expect(success).to be false
        expect(handled).to be true
      end
    end


    context 'any correct command used' do
      let(:all_cmds) { ['...', '&comb 0', '&deck'] }

      it 'does NOT affect data' do
        res = all_cmds.map do |cmd|
          old = board.data.deep_duplicate
          modify(transf, old, cmd) => {handled:, new_data:, success:}

          [handled, { old:, new_data:, success: }]
        end
        all_same = res.map(&:last).all? do |dat|
          dat[:old].wiped == dat[:new_data].wiped
        end

        all_handled = res.map(&:first).all? { |handled| handled }
        expect(all_same).to be true
        expect(all_handled).to be true
      end
    end
  end

  describe Transformations::CheatCommandsTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { Transformations::CheatCommandsTransformation.new }

    context 'correct %cget/%cheat.get command given' do
      let(:cards) { '2d 10s 6h' }
      it 'affects data' do
        ['%cget', '%cheat.get'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          old = board.data.deep_duplicate
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}


          expect(old.wiped).to_not be_eql(new_data.wiped)
          expect(old.player_decks).to_not be_eql(new_data.player_decks)
          expect(success).to be true
          expect(handled).to be true
        end
      end


      it 'alters player_decks properly but not drawboard' do
        ['%cget', '%cheat.get'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"

          old = board.data.deep_duplicate
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          cards_added = cards.split(' ').map { |c| Card.in(c) }

          expect(old.wiped).to_not be_eql(new_data.wiped)
          expect(new_data.player_decks[new_data.player]).to be_eql(old.player_decks[old.player] + cards_added)
          expect(old.drawboard).to be_eql(new_data.drawboard)
          expect(old.drawboard.cards.size).to be_eql(new_data.drawboard.cards.size)
          expect(success).to be true
          expect(handled).to be true
        end
      end
    end

    context 'correct %cdraw/%cheat.draw command given' do
      let(:cards) { '2d 10s 6h' }
      it 'affects data' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"
          old = board.data.deep_duplicate

          modify(transf, old, cmd_line) => {new_data:, handled:, success:}

          expect(old.wiped).to_not be_eql(new_data.wiped)
          expect(old.player_decks).to_not be_eql(new_data.player_decks)
          expect(old.drawboard).to_not be_eql(new_data.drawboard)
          expect(success).to be true
          expect(handled).to be true
        end
      end


      it 'alters player_decks and drawboard properly' do
        ['%cdraw', '%cheat.draw'].each do |cmd|
          cmd_line = "#{cmd} #{cards}"

          old = board.data.deep_duplicate
          modify(transf, old, cmd_line) => {new_data:, handled:, success:}
          cards_added = cards.split(' ').map { |c| Card.in(c) }


          expect(old.wiped).to_not be_eql(new_data.wiped)
          expect(new_data.player_decks[new_data.player]).to be_eql(old.player_decks[old.player] + cards_added)
          expect(new_data.drawboard.cards.size).to be_eql(old.drawboard.cards.size - cards_added.size)
          expect(success).to be true
          expect(handled).to be true
        end
      end
    end

    context 'NOT correct %cdraw/%cheat.draw command used' do
      context 'when argline empty' do
        let(:cards) { '' }
        it 'reports error' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            old = board.data.deep_duplicate
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first).to be_eql('No cards given')
            expect(success).to be false
            expect(handled).to be true
          end
        end
      end

      context 'when argline contains worng card' do
        let(:cards) { '10s 1000d 10x' }
        it 'reports error' do
          ['%cdraw', '%cheat.draw'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            old = board.data.deep_duplicate
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first.include?('No such card:')).to be true
            expect(success).to be false
            expect(handled).to be true
          end
        end
      end
    end


    context 'NOT correct %cget/%cheat.get command used' do
      context 'when argline empty' do
        let(:cards) { '' }
        it 'reports error' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            old = board.data.deep_duplicate
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first).to be_eql('No cards given')
            expect(success).to be false
            expect(handled).to be true
          end
        end
      end

      context 'when argline contains worng card' do
        let(:cards) { '10s 1000d 10x' }
        it 'reports error' do
          ['%cget', '%cheat.get'].each do |cmd|
            cmd_line = "#{cmd} #{cards}"
            old = board.data.deep_duplicate
            modify(transf, old, cmd_line) => {new_data:, handled:, success:, errors:}


            expect(errors.first.include?('No such card:')).to be true
            expect(success).to be false
            expect(handled).to be true
          end
        end
      end
    end
  end


  describe Transformations::MoveValidationTransformation do
    let(:board) { MachiavelliBoard.new(user_interface: console) }
    let(:transf) { Transformations::MoveValidationTransformation.new }

    before do
      board.data.table = [%w[2d 3d 4d 5d].map do |c|
                            Card.in(c)
                          end]
      board.data.player_decks[board.data.player] += [Card.of(diamond: 6)]
    end

    context 'correctly used p/put_card command' do
      let(:cmdd) { 'p0-3:0-4' }
      before do
        board.data.table = [%w[2d 3d 4d 5d].map do |c|
          Card.in(c)
        end]
        board.data.player_decks[board.data.player] += [Card.of(diamond: 6)]
      end


      it 'affects drawboard and deck properly' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {new_data:}

        expect(old.table.first.size).to be_eql(new_data.table.first.size - 1)
        expect(old.player_decks[old.player].size).to be_eql(new_data.player_decks[old.player].size + 1)
      end

      it 'doesnt report error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {handled:, success:, errors:}

        expect(success).to be true
        expect(handled).to be true
        expect(errors).to be_eql([])
      end
    end

    context 'NOT correctly used p/put_card command' do
      let(:cmdd) do
        'p.-3:0-4'
      end

      context 'when no card in deck' do
        before { board.data.player_decks[board.data.player] = [] }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such card in deck: .-3')
        end
      end

      context 'when no such combination' do
        before { board.data.table = [] }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such spot: 0-4')
        end
      end

      context 'when combination wont be valid' do
        before do
          s = board.data.player_decks[board.data.player].size
          board.data.player_decks[board.data.player][s - 1] = Card.of(diamond: 9)
          board.data.player_decks[:first_player][3] = Card.of(diamond: 9)
        end

        it 'report proper error' do
          oldd = board.data.deep_duplicate
          modify(transf, oldd, cmdd) => {handled:, success:, errors:}
          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('Neither iteration nor gradation')
        end
      end
    end


    context 'correctly used m/move_card command' do
      let(:cmdd) { 'm0-3:1-3' }
      before do
        a = %w[2d 3d 4d].map do |c|
          Card.in(c)
        end

        board.data.table = [a, a.dup]
        board.data.table[0] += [Card.of(diamond: 5)]
      end


      it 'affects table properly' do
        old = board.data.deep_duplicate

        modify(transf, old, cmdd) => {new_data:}

        expect(old.table.first.size).to be_eql(new_data.table.last.size)
        expect(old.table.last.size).to be_eql(new_data.table.first.size)

        expect(old.table.first).to be_eql(new_data.table.last)
        expect(old.table.last).to be_eql(new_data.table.first)
      end

      it 'doesnt report error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd, progress_move_optional: true) => {handled:, success:, errors:}
        expect(success).to be true
        expect(handled).to be true
        expect(errors).to be_eql([])
      end

      it 'does report no progress move error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {handled:, success:, errors:}
        expect(success).to be false
        expect(handled).to be true
        expect(errors).to be_eql(["You didnt get rid of any of your cards!"])
      end
    end

    context 'NOT correctly used m/move_card command' do
      let(:cmdd) { 'm0-3:1-3' }
      before do
        a = %w[2d 3d 4d].map do |c|
          Card.in(c)
        end

        board.data.table = [a, a.dup]
        board.data.table[0] += [Card.of(diamond: 5)]
      end

      context 'when no card in deck' do
        before { board.data.table[0] = board.data.table[..-1] }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such card in combination 0-3')
        end
      end

      context 'when no such combination' do
        before { board.data.table = [] }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such card in combination 0-3')
        end
      end

      context 'when combination wont be valid' do
        before do
          board.data.table[0] -= [Card.of(diamond: 5)] # not this valid card
          board.data.table[0] += [Card.of(spade: 10)] # but this invalid one
        end

        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('Neither iteration nor gradation')
        end
      end
    end


    context 'correctly used n/new_combination command' do
      let(:cmdd) { 'n.-0,.-1,.-2:_' }
      before do
        board.data.player_decks[board.data.player] = %w[2d 3d 4d].map do |c|
          Card.in(c)
        end

        # some extra combination to complicate
        board.data.table = [%w[2h 3h 4h 5h 6h].map do |c|
                              Card.in(c)
                            end]
      end


      it 'affects drawboard and deck properly' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {new_data:}

        expect(new_data.table.size).to be_eql(2)
        expect(new_data.table.last.size).to be_eql(3)
        expect(new_data.player_decks[old.player].size).to be_eql(0)
      end

      it 'doesnt report error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {handled:, success:, errors:}

        expect(success).to be true
        expect(handled).to be true
        expect(errors).to be_eql([])
      end
    end


    context 'correctly used b/break_combination command' do
      let(:cmdd) { 'b_:1-3' }
      before do
        comb_strs = [%w[2s 3s 4s], %w[2h 3h 4h 5h 6h 7h]]
        board.data.table = comb_strs.map do |comb|
          comb.map do |c|
            Card.in(c)
          end
        end
      end


      it 'affects table properly' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {new_data:}
        modify(transf, old, cmdd) => {new_data:, success:, handled:, errors:}

        expect(new_data.table.size).to be_eql(3)
        expect(new_data.table[2].size).to be_eql(3)
        expect(new_data.table[1].size).to be_eql(3)
      end

      it 'doesnt report error' do
        old = board.data.deep_duplicate
        modify(transf, old, cmdd) => {handled:, success:, errors:}

        expect(success).to be false
        expect(handled).to be true
        expect(errors).to be_eql(["You didnt get rid of any of your cards!"])
      end
    end


    context 'NOT correctly used b/split_combination command' do
      before do
        board.data.player_decks[board.data.player] = %w[2d 3d 4d].map do |c|
          Card.in(c)
        end

        # some extra combination to complicate
        board.data.table = [%w[2h 3h 4h 5h 6h].map do |c|
                              Card.in(c)
                            end]
      end



      context 'when no card in combination' do
        let(:cmdd) { 'b_:1-15' }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such spot: 1-15')
        end
      end

      context 'when no such combination' do
        let(:cmdd) { 'b_:15-3' }
        before { board.data.table = [] }
        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('No such spot: 15-3')
        end
      end

      context 'when combination wont be valid' do
        let(:cmdd) { 'b_:0-3' }

        before do
          board.data.table[0] -= [Card.of(hearth: 6)] # not this valid card
          board.data.table[0] += [Card.of(spade: 6)] # but this invalid one
        end

        it 'report proper error' do
          old = board.data.deep_duplicate
          modify(transf, old, cmdd) => {handled:, success:, errors:}

          expect(handled).to be true
          expect(success).to be false
          expect(errors.first).to be_eql('Too small combination: minimum 3 cards')
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
