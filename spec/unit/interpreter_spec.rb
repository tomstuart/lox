require 'stringio'
require 'lox/interpreter'

RSpec.describe Lox::Interpreter do
  let(:output) { double }
  let(:logger) { instance_double('Lox::Logger') }
  let(:scanner) { instance_double('Lox::Scanner') }

  subject(:interpreter) { Lox::Interpreter.new(output, logger) }

  before do
    class_double('Lox::Scanner', new: scanner).as_stubbed_const
  end

  describe '#run' do
    let(:output) { StringIO.new }
    let(:source) { double }
    let(:token_one) { instance_double('Lox::Token', to_s: 'token one') }
    let(:token_two) { instance_double('Lox::Token', to_s: 'token two') }
    let(:tokens) { [token_one, token_two] }

    before do
      allow(scanner).to receive(:each_token).and_yield(token_one).and_yield(token_two)
    end

    it 'fetches the tokens from the scanner' do
      interpreter.run(source)
      expect(scanner).to have_received(:each_token)
    end

    it 'converts each token to a string' do
      interpreter.run(source)
      expect(tokens).to all have_received(:to_s)
    end

    it 'outputs the string representation of each token' do
      interpreter.run(source)
      expect(output.string).to eq "token one\ntoken two\n"
    end
  end
end
