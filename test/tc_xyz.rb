# $Id: test_xyz.rb 156 2006-02-09 02:00:47Z tanaka $

require 'test/all'
require 'test/type_test'

class XyzTest < Test::Unit::TestCase
  include Chem::TypeTest

  def setup
    (@entries = []).push Chem.open_mol($data_dir + "test.xyz")
    @parser = Chem::XYZ::XyzMolecule
    @file_type = Chem::Type::XyzType
  end

end
