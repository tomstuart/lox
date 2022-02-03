require 'lox/scanner'

RSpec.describe Lox::Scanner do
  describe '#each_token' do
    describe 'tokenising' do
      it 'tokenises the empty string' do
        expect('').to tokenise_as(
          { type: :eof }
        )
      end
    end
  end

  matcher :tokenise_as do |*expected_token_attributes|
    match do |source|
      scanner = Lox::Scanner.new(source, logger)
      actual_tokens = scanner.each_token
      actual_token_attributes =
        actual_tokens.zip(expected_token_attributes).map do |actual, expected|
          expected ? actual.to_h.slice(*expected.keys) : actual.to_h
        end
      @actual = actual_token_attributes

      expect(actual_token_attributes).to eq expected_token_attributes
    end

    chain :with_error do |message|
      expect(logger).to receive(:error).with(a_kind_of(Integer), message)
    end

    def logger
      @logger ||= instance_double('Lox::Logger')
    end

    diffable
  end
end
