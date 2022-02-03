require 'lox/lookahead_iterator'

RSpec.describe Lox::LookaheadIterator do
  let(:enumerator) { 'hello world'.each_char }

  subject(:lookahead_iterator) { Lox::LookaheadIterator.new(enumerator) }

  shared_examples 'iterating from the beginning' do
    describe '#each' do
      it 'iterates through the early elements' do
        expect(5.times.map { lookahead_iterator.next }).to eq %w[h e l l o]
      end

      it 'raises StopIteration if it iterates too far' do
        expect { 12.times { lookahead_iterator.next } }.to raise_error(StopIteration)
      end
    end

    describe '#peek' do
      it 'looks ahead by a single element by default' do
        expect(lookahead_iterator.peek).to eq 'h'
      end

      it 'looks ahead by several elements' do
        expect(lookahead_iterator.peek(lookahead: 4)).to eq 'o'
      end

      it 'raises StopIteration if it looks ahead too far' do
        expect { lookahead_iterator.peek(lookahead: 11) }.to raise_error(StopIteration)
      end
    end
  end

  shared_examples 'iterating from halfway through' do
    describe '#each' do
      it 'iterates through the late elements' do
        expect(5.times.map { lookahead_iterator.next }).to eq %w[w o r l d]
      end

      it 'raises StopIteration if it iterates too far' do
        expect { 6.times { lookahead_iterator.next } }.to raise_error(StopIteration)
      end
    end

    describe '#peek' do
      it 'looks ahead by a single element by default' do
        expect(lookahead_iterator.peek).to eq 'w'
      end

      it 'looks ahead by several elements' do
        expect(lookahead_iterator.peek(lookahead: 4)).to eq 'd'
      end

      it 'raises StopIteration if it looks ahead too far' do
        expect { lookahead_iterator.peek(lookahead: 5) }.to raise_error(StopIteration)
      end
    end
  end

  context 'before any iteration or lookahead' do
    include_examples 'iterating from the beginning'
  end

  context 'after some lookahead' do
    before do
      6.times { |lookahead| lookahead_iterator.peek(lookahead:) }
    end

    include_examples 'iterating from the beginning'
  end

  context 'after some iteration' do
    before do
      6.times { lookahead_iterator.next }
    end

    include_examples 'iterating from halfway through'
  end

  context 'after some iteration and lookahead' do
    before do
      6.times { lookahead_iterator.next }
      5.times { |lookahead| lookahead_iterator.peek(lookahead:) }
    end

    include_examples 'iterating from halfway through'
  end

  describe 'peeking whenever possible' do
    let(:enumerator) { double }

    before do
      allow(enumerator).to receive(:peek)
      allow(enumerator).to receive(:next)
    end

    context 'before any lookahead' do
      it 'peeks the underlying enumerator if possible' do
        expect(enumerator).not_to receive(:next)
        expect(enumerator).to receive(:peek).once

        lookahead_iterator.peek
      end

      it 'iterates and peeks the underlying enumerator if necessary' do
        expect(enumerator).to receive(:next).twice.ordered
        expect(enumerator).to receive(:peek).once.ordered

        lookahead_iterator.peek(lookahead: 2)
      end
    end

    context 'after some lookahead' do
      before do
        lookahead_iterator.peek(lookahead: 2)
      end

      it 'peeks the underlying enumerator if possible' do
        expect(enumerator).not_to receive(:next)
        expect(enumerator).to receive(:peek).once

        lookahead_iterator.peek(lookahead: 2)
      end

      it 'iterates and peeks the underlying enumerator if necessary' do
        expect(enumerator).to receive(:next).once.ordered
        expect(enumerator).to receive(:peek).once.ordered

        lookahead_iterator.peek(lookahead: 3)
      end
    end
  end
end
