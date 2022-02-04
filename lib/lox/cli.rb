require 'lox/interpreter'
require 'lox/logger'

module Lox
  class CLI
    def initialize(input, output)
      self.input = input
      self.output = output
      self.logger = Logger.new(output)
      self.interpreter = Interpreter.new(output, logger)
    end

    def start(args)
      case args
      in [filename]
        run_file(filename)
      in []
        run_prompt
      else
        output.puts "Usage: #{$PROGRAM_NAME} [script]"
        exit(64)
      end
    end

    private

    attr_accessor :input, :output, :logger, :interpreter

    def run_file(filename)
      File.open(filename) do |source|
        interpreter.run(source)
      end
      exit(65) if logger.has_errored?
    end

    def run_prompt
      loop do
        output.print '> '
        break unless line = input.gets
        interpreter.run(line)
        logger.clear_errors
      end
    end
  end
end
