module Lox
  class CLI
    def initialize(input, output)
      self.input = input
      self.output = output
    end

    def start(args)
      output.puts "Usage: #{$PROGRAM_NAME} [script]"
      exit(64)
    end

    private

    attr_accessor :input, :output
  end
end
