require 'open3'

RSpec.describe 'the Lox interpreter' do
  CHAPTERS = {
    chap04_scanning:    :done,
    chap06_parsing:     :todo,
    chap07_evaluating:  :todo,
    chap08_statements:  :todo,
    chap09_control:     :todo,
    chap10_functions:   :todo,
    chap11_resolving:   :todo,
    chap12_classes:     :todo,
    chap13_inheritance: :todo
  }

  INTERPRETER_PATH = 'bin/lox'
  PROJECT_DIR = File.expand_path('../..', __dir__)
  BOOK_DIR = ENV['BOOK_DIR']

  [
    CHAPTERS.reverse_each.detect { |_, status| status == :done },
    CHAPTERS.detect { |_, status| status == :wip }
  ].compact.each do |chapter, status|
    it "passes the #{chapter} test suite" do
      skip 'acceptance tests disabled (set BOOK_DIR to enable)' unless BOOK_DIR
      pending "#{chapter} is work in progress" if status == :wip

      output, error, status =
        Open3.capture3 \
          'dart',
          'tool/bin/test.dart',
          chapter.to_s,
          '--interpreter',
          File.expand_path(INTERPRETER_PATH, PROJECT_DIR),
          chdir: BOOK_DIR

      failure_message = error.empty? ? (output.slice(%r{^FAIL(.+\n)+}) || output) : error
      expect(status).to be_success, failure_message
    end
  end
end
