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

      yield Token.new(type: :eof, lexeme: '', line:)
    end

    private

    attr_accessor :characters, :logger, :line
  end
end
