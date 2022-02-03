RSpec.describe do
  matcher :tokenise_as do |*expected_token_attributes|
    match do |source|
      logger = instance_double('Lox::Logger')
      scanner = Lox::Scanner.new(source, logger)
      actual_tokens = scanner.each_token
      actual_token_attributes =
        actual_tokens.zip(expected_token_attributes).map do |actual, expected|
          expected ? actual.to_h.slice(*expected.keys) : actual.to_h
        end
      @actual = actual_token_attributes

      expect(actual_token_attributes).to eq expected_token_attributes
    end

    diffable
  end
end
