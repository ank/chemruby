# $Id: test_sdf.rb 151 2006-02-08 08:21:08Z tanaka $

require 'test/unit'
require 'chem'
require 'test/type_test'
require 'chem/db/types/type_sdf'

require 'test/multiple_test'

class SdfTest < Test::Unit::TestCase

  include Chem::MultipleTest

  def setup
    @entries = Chem.open_mol($data_dir + "test.sdf")
    @file_type = Chem::Type::SdfType
    @mod = Chem::MDL::SdfParser
  end

  def test_autodetection
    assert_equal(Chem::Type::SdfType, Chem::autodetect($data_dir + "test.sdf"))
  end

  def test_sdf_file
    assert_equal(2, @entries.to_a.length)
    @entries.each do |mol|
      assert_not_nil(mol)
    end
    assert_equal(2, Chem.open_mol($data_dir + "test_lf.sdf").to_a.length)
  end
  
end
