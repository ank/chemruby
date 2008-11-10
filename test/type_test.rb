# $Id: type_test.rb 61 2005-10-12 09:17:39Z tanaka $

module Chem
  # A test module for testing ``autodetect'' mechanism
  # Modules that test autodetection must conform this test.

  module TypeTest

    def test_db_mod
      assert(@file_type.respond_to?(:parse),
             "Type modules must respond to parse(file) method")
      assert(@file_type.respond_to?(:detect_file),
             "Type modules must respond to detect_file method")
      assert(@file_type.respond_to?(:detect_type),
             "Type modules must respond to detect_type method")
    end

    def test_autodetect
      @entries.each do |entry|
#        assert_instance_of(@parser, entry)
      end
    end

  end
end
