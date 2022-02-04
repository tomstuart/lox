require 'lox/scanner'

module Lox
  class Interpreter
    def initialize(output, logger)
      self.output = output
      self.logger = logger
    end

    def run(source)
      scanner = Scanner.new(source, logger)

      scanner.each_token do |token|
        output.puts token
      end
    end

    private

    attr_accessor :output, :logger
  end
end
