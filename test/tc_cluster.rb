# $Id: test_mdl.rb 37 2005-09-23 22:58:24Z tanaka $

# Tests to ensure functionality

require 'test/all'

class ClusterTest < Test::Unit::TestCase

  def test_morgan
    #    mol = Chem.open_mol(File.join($data_dir, "hypericin.mol"))
    #mol = Chem.parse_smiles("C1CC1")
#    require 'chem/db/smiles'
    require 'chem/db/smiles/smiparser'
    mol = SMILES("C1CC1")
    assert_equal([2, 2, 2], mol.clustering_coefficient.values)
#    ec, tec, priority = mol.morgan#_index
  end

end
