# $Id: test_mdl.rb 37 2005-09-23 22:58:24Z tanaka $

# Tests to ensure functionality

require 'test/all'

require 'chem'

class MorganTest < Test::Unit::TestCase

  def test_morgan
    mol = Chem.open_mol(File.join($data_dir, "hypericin.mol"))
    ec, tec, priority = mol.morgan#_index
    require 'set'
    assert_equal(Set.new([82, 123, 184, 216, 164, 120, 227, 216, 164, 153,
                   184, 123, 82, 120, 184, 216, 227, 216, 184, 123,
                   82, 120, 164, 153, 164, 120, 82, 123, 40, 42, 51,
                   40, 42, 42, 40, 51, 40, 42]), Set.new(ec.values))
  end

end
