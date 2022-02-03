module Lox
  class LookaheadIterator
    def initialize(enumerator)
      self.enumerator = enumerator
      self.buffer = []
    end

    def next
      if buffer.empty?
        enumerator.next
      else
        buffer.shift
      end
    end

    def peek(lookahead: 0)
      buffer.push(enumerator.next) until lookahead <= buffer.length

      if lookahead < buffer.length
        buffer.slice(lookahead)
      else
        enumerator.peek
      end
    end

    private

    attr_accessor :enumerator, :buffer
  end
end
