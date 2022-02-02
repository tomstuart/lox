require 'stringio'
require 'lox/logger'

RSpec.describe Lox::Logger do
  let(:output) { double }

  subject(:logger) { Lox::Logger.new(output) }

  context 'when no errors have been logged' do
    it { is_expected.not_to have_errored }
  end

  context 'when an error has been logged' do
    let(:output) { StringIO.new }
    let(:line) { 42 }
    let(:message) { 'Something went wrong' }

    before do
      logger.error(line, message)
    end

    it { is_expected.to have_errored }

    it 'includes the line number in the log message' do
      expect(output.string).to include "line #{line}"
    end

    it 'includes the error in the log message' do
      expect(output.string).to include message
    end

    context 'and then cleared' do
      before do
        logger.clear_errors
      end

      it { is_expected.not_to have_errored }
    end
  end
end
