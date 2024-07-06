# frozen_string_literal: true

# spec/move_Action_spec.rb
require_relative '..\..\app\gamelogic\action'

describe Action do
  describe '::from' do
    context 'given correct string' do
      let(:str) { sample_str(valid: true) }

      it 'returns valid Action' do
        # byebug
        expect(Action.from(str)).to_not be_nil
      end
    end

    context 'given correct complex string' do
      let(:str) { 'n.-0,1-2,5-3:_' }


      it 'returns valid Action' do
        expect(Action.from(str)).to_not be_nil
      end

      it 'has proper properties' do
        a = Action.from(str)

        # expect(a.name).to eql(:new_combination)
        # expect(a.origin).to eql([[0, 0], [1, 2], [5, 3]])
        # expect(a.destination).to eql([0, 0])
        act = Action.new(:new_combination, [[0, 0], [1, 2], [5, 3]], [0, 0])
        expect(a).to eql(act)
      end
    end

    context 'given NOT correct string' do
      let(:strs) { 20.times.map { sample_str(valid: false) } }

      it 'returns valid Action' do
        expect(strs.map { |s| Action.from(s) }.all?(&:nil?)).to be true
      end
    end
  end
end


def sample_str(valid:)
  valid ? sample_valid_str : sample_not_valid_str
end

def sample_valid_str
  letter = Action.action_shorts.keys.sample
  pairs_num = rand(2..4)

  pairs = pairs_num.times.map do |_idx|
    a = rand(100)
    b = rand(100)
    "#{a}-#{b}"
  end

  "#{letter}#{pairs[..-1].join(',')}:#{pairs.last}"
end

def sample_not_valid_str
  str = sample_valid_str

  toswap = { 0 => ['-', '='], 2 => [',', ' '], 4 => [':', ' '] }

  n = rand(5)
  if [0, 2, 4].include?(n)
    str.gsub!(*(toswap[n]))
  else
    str = n == 1 ? option1(str) : option3(str)
  end

  str
end

def option1(str)
  '0123456789'.chars.each do |c|
    str.gsub!(c, '?')
  end
  str
end

def option3(str)
  str[1..]
end
