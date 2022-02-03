require 'lox/scanner'

RSpec.describe Lox::Scanner do
  describe '#each_token' do
    shared_examples 'tokenising' do
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

      it 'tokenises slashes' do
        expect('(/)').to tokenise_as(
          { type: :left_paren },
          { type: :slash },
          { type: :right_paren },
          { type: :eof }
        )
      end

      it 'ignores comments' do
        expect('(/)// hello world').to tokenise_as(
          { type: :left_paren },
          { type: :slash },
          { type: :right_paren },
          { type: :eof }
        )
      end

      it 'ignores whitespace' do
        expect(" ( \t ) \n { \r } ").to tokenise_as(
          { type: :left_paren },
          { type: :right_paren },
          { type: :left_brace },
          { type: :right_brace },
          { type: :eof }
        )
      end

      it 'keeps track of the current line number' do
        expect(";)\n;)\n;)").to tokenise_as(
          { type: :semicolon, line: 1 },
          { type: :right_paren, line: 1 },
          { type: :semicolon, line: 2 },
          { type: :right_paren, line: 2 },
          { type: :semicolon, line: 3 },
          { type: :right_paren, line: 3 },
          { type: :eof }
        )
      end
    end

    shared_examples 'error handling' do
      it 'skips an unexpected character and reports an error' do
        expect('(#)').to tokenise_as(
          { type: :left_paren },
          { type: :right_paren },
          { type: :eof }
        ).with_error('Unexpected character')
      end
    end

    shared_examples 'EOF handling' do
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

      it 'tokenises a string ending with a slash' do
        expect('*/').to tokenise_as(
          { type: :star },
          { type: :slash },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with an empty comment' do
        expect('*//').to tokenise_as(
          { type: :star },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with a non-empty comment' do
        expect('*// world').to tokenise_as(
          { type: :star },
          { type: :eof }
        )
      end
    end

    context 'without a trailing newline' do
      def prepare_source(source)
        source
      end

      include_examples 'tokenising'
      include_examples 'error handling'
      include_examples 'EOF handling'
    end
  end

  matcher :tokenise_as do |*expected_token_attributes|
    match do |source|
      scanner = Lox::Scanner.new(prepare_source(source), logger)
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
