require 'lox/token'

RSpec.describe Lox::Token do
  let(:type) { double }
  let(:lexeme) { double }
  let(:line) { double }

  context 'without a literal' do
    subject(:token) { Lox::Token.new(type:, lexeme:, line:) }

    describe 'getters' do
      it { is_expected.to have_attributes(type:, lexeme:, line:) }
      it { is_expected.to have_attributes(literal: nil) }
    end

    describe '#to_s' do
      before do
        allow(type).to receive(:to_s).and_return('star')
        allow(lexeme).to receive(:to_s).and_return('*')
      end

      it 'concatenates the type, lexeme and “null”, upcasing the type' do
        expect(token.to_s).to eq 'STAR * null'
      end
    end
  end

  context 'with a literal' do
    let(:literal) { double }

    subject(:token) { Lox::Token.new(type:, lexeme:, literal:, line:) }

    describe 'getters' do
      it { is_expected.to have_attributes(type:, lexeme:, literal:, line:) }
    end

    describe '#to_s' do
      before do
        allow(type).to receive(:to_s).and_return('number')
        allow(lexeme).to receive(:to_s).and_return('42')
        allow(literal).to receive(:to_s).and_return('42.0')
      end

      it 'concatenates the type, lexeme and literal, upcasing the type' do
        expect(token.to_s).to eq 'NUMBER 42 42.0'
      end
    end
  end
end
