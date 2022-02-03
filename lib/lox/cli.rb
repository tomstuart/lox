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
  end
end
