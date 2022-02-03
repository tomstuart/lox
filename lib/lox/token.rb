module Lox
  Token = Struct.new(:type, :lexeme, :literal, :line, keyword_init: true) do
    def to_s
      [type.to_s.upcase, lexeme, literal || 'null'].join(' ')
    end
  end
end
