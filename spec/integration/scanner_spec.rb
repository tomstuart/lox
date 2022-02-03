require 'lox/scanner'

RSpec.describe Lox::Scanner do
  describe '#each_token' do
    describe 'tokenising' do
      it 'tokenises the empty string' do
        expect('').to tokenise_as(
          { type: :eof }
        )
      end

      it 'tokenises simple operators' do
        expect('(){},.-+;*').to tokenise_as(
          { type: :left_paren },
          { type: :right_paren },
          { type: :left_brace },
          { type: :right_brace },
          { type: :comma },
          { type: :dot },
          { type: :minus },
          { type: :plus },
          { type: :semicolon },
          { type: :star },
          { type: :eof }
        )
      end

      it 'tokenises compound operators' do
        expect('==!!=<<=>>==').to tokenise_as(
          { type: :equal_equal },
          { type: :bang },
          { type: :bang_equal },
          { type: :less },
          { type: :less_equal },
          { type: :greater },
          { type: :greater_equal },
          { type: :equal },
          { type: :eof }
        )
      end
    end

    describe 'error handling' do
      it 'skips an unexpected character and reports an error' do
        expect('(#)').to tokenise_as(
          { type: :left_paren },
          { type: :right_paren },
          { type: :eof }
        ).with_error('Unexpected character')
      end
    end

    describe 'EOF handling' do
      it 'tokenises a string ending with a one-character compound operator' do
        expect('*<').to tokenise_as(
          { type: :star },
          { type: :less },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with a two-character compound operator' do
        expect('*<=').to tokenise_as(
          { type: :star },
          { type: :less_equal },
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
