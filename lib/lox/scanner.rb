require 'lox/token'

module Lox
  class Scanner
    def initialize(source, logger)
      self.characters = source.each_char
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
      read_character
      logger.error(line, 'Unexpected character')
      read_token
    end

    def read_character
      characters.next
    end
  end
end
