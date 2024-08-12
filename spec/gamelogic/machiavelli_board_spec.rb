# frozen_string_literal: true

# spec/machiavelliboard_spec.rb
require_relative '../../app/gamelogic/machiavelli_board'

describe MachiavelliBoard do
  let(:board) { described_class.new }

  describe '#initialize' do
    let(:b) { described_class.new }
    let(:c) do
      c = b.data.deep_duplicate
      c.player_decks = c.player_decks.map { |k, _v| [k, []] }.to_h
      c.drawboard = Drawboard.fresh
      c.drawboard.order
      c
    end

    it 'creates fresh data instance' do
      expect(c.wiped).to eql(GameData.fresh.wiped)
    end

    it 'prepares cards' do
      expect(b.data.player_decks[b.data.player].size).to be(3)
    end
  end

  describe '#reset_game' do
    let(:altered_board) do
      board.data.drawboard = []
      board.data.game_status = { finished: true, give_up: true, winner: board.data.player }
      board
    end

    before { altered_board.reset_game }

    it 'affects data' do
      fgd = GameData.fresh.wiped
      fgd.player_decks = altered_board.data.player_decks # because these are random
      fgd.drawboard.cards = altered_board.data.drawboard.cards # because these are affected by above

      expect(altered_board.data.wiped).to eql(fgd.wiped)
    end
  end

  describe '#make_move' do
    context 'with string passed' do
      let(:good_str) { 'd' }

      it 'does NOT report error' do
        board.make_move(good_str) => {error:, ok:}

        expect(ok).to be true
      end

      it 'affects data' do
        old = board.data.deep_duplicate
        board.make_move(good_str)

        expect(old.wiped).not_to eql(board.data.wiped)
      end
    end

    context 'with NOT correct string passed' do
      let(:bad_str) { 'wrong' }

      it 'is not ok' do
        board.make_move(bad_str) => {ok:, error:}

        expect(ok).to be false
      end

      it 'reports error' do
        board.make_move(bad_str) => {ok:, error:}

        expect(error).to eql("Incorrect action: 'wrong'")
      end

      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        board.make_move(bad_str)

        expect(old.wiped).to eql(board.data.wiped)
      end
    end
  end

  context 'when player won because of empty deck' do
    before do
      board.data.player_decks[board.data.player] = []
      board.check_win
    end

    it 'reports win' do
      expect(board.won?).to be true
    end

    it 'does NOT report forfeit' do
      expect(board.gave_up?).to be false
    end

    it 'says that the game ended' do
      expect(board.game_ended?).to be true
    end
  end

  context 'when game still in progres' do
    before do
      board.check_win
    end


    it 'does NOT report win' do
      expect(board.won?).to be false
    end

    it 'does NOT report forfeit' do
      expect(board.gave_up?).to be false
    end

    it 'does NOT say that the game ended' do
      expect(board.game_ended?).to be false
    end
  end

  context 'when one player has given up' do
    before do
      # board.data.game_status[:winner] = board.data.player
      board.data.drawboard.cards = []
      board.make_move('g')
      board.check_win
    end

    it 'does NOT report win' do
      expect(board.won?).to be false
    end

    it 'reports forfeit' do
      expect(board.gave_up?).to be true
    end

    it 'says that the game ended' do
      expect(board.game_ended?).to be true
    end
  end
end
