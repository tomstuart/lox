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

      it 'tokenises string literals' do
        expect('"hello world"').to tokenise_as(
          { type: :string, literal: 'hello world' },
          { type: :eof }
        )
      end

      it 'records a string literal’s final line number' do
        expect(%Q{";)\n;)\n;)"}).to tokenise_as(
          { type: :string, literal: ";)\n;)\n;)", line: 3 },
          { type: :eof }
        )
      end

      it 'tokenises numbers without a fractional part' do
        expect('123 456').to tokenise_as(
          { type: :number, literal: 123 },
          { type: :number, literal: 456 },
          { type: :eof }
        )
      end

      it 'tokenises numbers with a fractional part' do
        expect('123.456 78.9').to tokenise_as(
          { type: :number, literal: 123.456 },
          { type: :number, literal: 78.9 },
          { type: :eof }
        )
      end

      it 'tokenises a number before a dot' do
        expect('123. 78.').to tokenise_as(
          { type: :number, literal: 123 },
          { type: :dot },
          { type: :number, literal: 78 },
          { type: :dot },
          { type: :eof }
        )
      end

      it 'tokenises a number after a dot' do
        expect('.123 .78').to tokenise_as(
          { type: :dot },
          { type: :number, literal: 123 },
          { type: :dot },
          { type: :number, literal: 78 },
          { type: :eof }
        )
      end

      it 'tokenises identifiers' do
        expect('1hello2 _world_').to tokenise_as(
          { type: :number, literal: 1 },
          { type: :identifier, lexeme: 'hello2' },
          { type: :identifier, lexeme: '_world_' },
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

      it 'reports an error for an unterminated string literal' do
        expect('* "hello').to tokenise_as(
          { type: :star },
          { type: :eof }
        ).with_error('Unterminated string')
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

      it 'tokenises a string ending with a number with no fractional part' do
        expect('*42').to tokenise_as(
          { type: :star },
          { type: :number, literal: 42.0 },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with a number followed by a dot' do
        expect('*42.').to tokenise_as(
          { type: :star },
          { type: :number, literal: 42.0 },
          { type: :dot },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with a number with a fractional part' do
        expect('*42.1').to tokenise_as(
          { type: :star },
          { type: :number, literal: 42.1 },
          { type: :eof }
        )
      end

      it 'tokenises a string ending with an identifier' do
        expect('hello world').to tokenise_as(
          { type: :identifier, lexeme: 'hello' },
          { type: :identifier, lexeme: 'world' },
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

    context 'with a trailing newline' do
      def prepare_source(source)
        "#{source}\n"
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
