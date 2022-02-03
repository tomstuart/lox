require 'stringio'
require 'lox/cli'

RSpec.describe Lox::CLI do
  let(:input) { double }
  let(:output) { double }
  let(:logger) { instance_double('Lox::Logger') }
  let(:interpreter) { instance_double('Lox::Interpreter') }

  subject(:cli) { Lox::CLI.new(input, output) }

  before do
    class_double('Lox::Logger', new: logger).as_stubbed_const
    class_double('Lox::Interpreter', new: interpreter).as_stubbed_const
  end

  describe '#start' do
    context 'with a filename argument' do
      let(:file) { double }
      let(:filename) { double }
      let(:arguments) { [filename] }

      before do
        allow(File).to receive(:open).and_yield(file)
        allow(interpreter).to receive(:run)
        allow(logger).to receive(:has_errored?).and_return(false)
      end

      it 'opens the file' do
        cli.start(arguments)
        expect(File).to have_received(:open).with(filename)
      end

      it 'evaluates the file' do
        cli.start(arguments)
        expect(interpreter).to have_received(:run).with(file)
      end

      context 'when there are no errors' do
        it 'returns normally' do
          expect { cli.start(arguments) }.not_to raise_error
        end
      end

      context 'when there are errors' do
        before do
          allow(logger).to receive(:has_errored?).and_return(true)
        end

        it 'exits with status 65 (`EX_DATAERR`)' do
          expect { cli.start(arguments) }.to raise_error(SystemExit) do |error|
            expect(error.status).to eq 65
          end
        end
      end
    end

    context 'with no arguments' do
      let(:lines) { ["hello world\n", "goodbye world\n"] }
      let(:input) { StringIO.new(lines.join) }
      let(:output) { StringIO.new }
      let(:arguments) { [] }

      before do
        allow(interpreter).to receive(:run)
        allow(logger).to receive(:clear_errors)
        allow(logger).to receive(:has_errored?).and_return(false)
      end

      it 'prompts for user input' do
        cli.start(arguments)
        expect(output.string).to start_with('> ')
      end

      it 'reads and evaluates the user input' do
        cli.start(arguments)

        lines.each do |line|
          expect(interpreter).to have_received(:run).with(line).ordered
        end
      end

      it 'clears the logger’s error state after each evaluation' do
        cli.start(arguments)
        expect(logger).to have_received(:clear_errors).exactly(lines.length).times
      end
    end

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
