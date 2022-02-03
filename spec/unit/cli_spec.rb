require 'stringio'
require 'lox/cli'

RSpec.describe Lox::CLI do
  let(:input) { double }
  let(:output) { double }

  subject(:cli) { Lox::CLI.new(input, output) }

  describe '#start' do
    context 'with unrecognised arguments' do
      let(:output) { StringIO.new }
      let(:arguments) { [double, double] }

      it 'prints a usage message' do
        begin
          cli.start(arguments)
        rescue SystemExit
        end

        expect(output.string).to start_with('Usage:')
      end

      it 'exits with status 64 (`EX_USAGE`)' do
        expect { cli.start(arguments) }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq 64
        end
      end
    end
  end
end
