module Lox
  class Logger
    def initialize(output)
      self.output = output
      clear_errors
    end

    def error(line, message)
      report(line, '', message)
    end

    def clear_errors
      self.errored = false
    end

    def has_errored?
      errored
    end

    private

    attr_accessor :output, :errored

    def report(line, where, message)
      output.puts "[line #{line}] Error#{where}: #{message}"
      self.errored = true
    end
  end
end
