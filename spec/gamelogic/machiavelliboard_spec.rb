# frozen_string_literal: true

# spec/machiavelliboard_spec.rb
require_relative '..\..\app\gamelogic\machiavelliboard'

describe MachiavelliBoard do
  let(:board) { MachiavelliBoard.new }

  it 'initializes' do
    b = MachiavelliBoard.new
    c = b.data.deep_duplicate
    c.player_decks = c.player_decks.map { |k, _v| [k, []] }.to_h
    c.drawboard = Drawboard.fresh
    c.drawboard.order
    # byebug
    # byebug
    expect(c.wiped).to eql(GameData.fresh.wiped)
    expect(b.data.player_decks[b.data.player].size).to eql(3)
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
      # byebug
      expect(altered_board.data.wiped).to be_eql(fgd.wiped)
    end
  end

  describe '#make_move' do
    context 'when correct string passed ' do
      let(:good_str) { 'd' }

      it 'does NOT report error' do
        board.make_move(good_str) => {error:, ok:}

        expect(ok).to be true
      end

      it 'affects data' do
        old = board.data.deep_duplicate
        board.make_move(good_str)

        expect(old.wiped).to_not be_eql(board.data.wiped)
      end
    end

    context 'when incorrect string passed' do
      let(:bad_str) { 'wrong' }

      it 'reports error' do
        board.make_move(bad_str) => {ok:, error:}

        expect(ok).to be false
        expect(error).to be_eql("Incorrect action: 'wrong'")
      end

      it 'does NOT affect data' do
        old = board.data.deep_duplicate
        board.make_move(bad_str)

        expect(old.wiped).to be_eql(board.data.wiped)
      end
    end
  end

  context 'when player won because of empty deck' do
    before do
      board.data.player_decks[board.data.player] = []
      board.check_win
    end

    it 'reports win' do
      # byebug
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

  context 'when one player given up' do
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
