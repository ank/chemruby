# $Id: multiple_test.rb 88 2005-12-27 11:52:43Z tanaka $

# Parsers that parse files with multiple molecule should conform
# MultipleTest.

module Chem
  module MultipleTest

    def test_prerequisite
      assert_not_nil(@entries)
      assert_not_nil(@file_type)

      assert_kind_of(Enumerable, @entries)
    end

    def test_respond
      assert_respond_to(@entries, :each)
      assert(@entries.all?{|entry| entry.respond_to?(:entry)}, "all entries responds to 'entry' method")
    end

  end
end
