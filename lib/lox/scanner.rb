require 'lox/lookahead_iterator'
require 'lox/token'

module Lox
  class Scanner
    EQUAL, SLASH = %w[= /]
    NEWLINE = "\n"

    SIMPLE_OPERATORS =
      {
        '(' => :left_paren,
        ')' => :right_paren,
        '{' => :left_brace,
        '}' => :right_brace,
        ',' => :comma,
        '.' => :dot,
        '-' => :minus,
        '+' => :plus,
        ';' => :semicolon,
        '*' => :star,
        SLASH => :slash
      }

    COMPOUND_OPERATORS =
      {
        '!' => :bang,
        EQUAL => :equal,
        '<' => :less,
        '>' => :greater
      }

    def initialize(source, logger)
      self.characters = LookaheadIterator.new(source.each_char)
      self.logger = logger
      self.line = 1
    end

    def each_token
      return enum_for(__method__) unless block_given?

      loop do
        yield read_token
      end

      yield Token.new(type: :eof, lexeme: '', line:)
    end

    private

    attr_accessor :characters, :logger, :line

    def read_token
      skip_comments

      case next_character
      when *SIMPLE_OPERATORS.keys
        lexeme = read_character
        type = SIMPLE_OPERATORS.fetch(lexeme)
        Token.new(type:, lexeme:, line:)
      when *COMPOUND_OPERATORS.keys
        lexeme = read_character
        type = COMPOUND_OPERATORS.fetch(lexeme)
        stop_at_eof do
          if next_character == EQUAL
            lexeme << read_character(EQUAL)
            type = :"#{type}_equal"
          end
        end
        Token.new(type:, lexeme:, line:)
      else
        read_character
        logger.error(line, 'Unexpected character')
        read_token
      end
    end

    def skip_comments
      loop do
        if 2.times.all? { |lookahead| next_character(lookahead:) == SLASH }
          2.times { read_character(SLASH) }
          read_character until next_character == NEWLINE
        else
          break
        end
      end
    end

    def next_character(lookahead: 0)
      characters.peek(lookahead:)
    end

    def read_character(expected = nil)
      characters.next.tap do |actual|
        raise unless actual == expected || expected.nil?
      end
    end

    def stop_at_eof
      begin
        yield
      rescue StopIteration
      end
    end
  end
end
