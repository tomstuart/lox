require 'lox/lookahead_iterator'
require 'lox/token'

module Lox
  class Scanner
    DOT, EQUAL, QUOTE, SLASH = %w[. = " /]
    WHITESPACE = ' ', "\t", "\r", (NEWLINE = "\n")

    SIMPLE_OPERATORS =
      {
        '(' => :left_paren,
        ')' => :right_paren,
        '{' => :left_brace,
        '}' => :right_brace,
        ',' => :comma,
        DOT => :dot,
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
      skip_whitespace_and_comments

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
      when QUOTE
        read_string_token
      when method(:digit?)
        read_number_token
      else
        read_character
        logger.error(line, 'Unexpected character')
        read_token
      end
    end

    def skip_whitespace_and_comments
      loop do
        if WHITESPACE.include?(next_character)
          whitespace = read_character
          self.line += 1 if whitespace == NEWLINE
        elsif 2.times.all? { |lookahead| next_character(lookahead:) == SLASH }
          2.times { read_character(SLASH) }
          read_character until next_character == NEWLINE
        else
          break
        end
      end
    end

    def read_string_token
      lexeme = ''
      lexeme << read_character(QUOTE)
      error_at_eof 'Unterminated string' do
        until next_character == QUOTE
          character = read_character
          lexeme << character
          self.line += 1 if character == NEWLINE
        end
      end
      lexeme << read_character(QUOTE)
      literal = lexeme.slice(1...-1)

      Token.new(type: :string, lexeme:, literal:, line:)
    end

    def read_number_token
      lexeme = ''
      stop_at_eof do
        lexeme << read_character while digit?(next_character)
        if next_character == DOT && digit?(next_character(lookahead: 1))
          lexeme << read_character(DOT)
          lexeme << read_character while digit?(next_character)
        end
      end
      literal = Float(lexeme)

      Token.new(type: :number, lexeme:, literal:, line:)
    end

    def next_character(lookahead: 0)
      characters.peek(lookahead:)
    end

    def read_character(expected = nil)
      characters.next.tap do |actual|
        raise unless actual == expected || expected.nil?
      end
    end

    def digit?(character)
      ('0'..'9').include?(character)
    end

    def stop_at_eof
      begin
        yield
      rescue StopIteration
      end
    end

    def error_at_eof(message)
      begin
        yield
      rescue StopIteration
        logger.error(line, message)
        raise
      end
    end
  end
end
