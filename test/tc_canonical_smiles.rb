#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_canonical_smiles.rb 127 2006-02-03 02:47:57Z tanaka $
#

require 'test/all'

class CanonicalSmilesTest < Test::Unit::TestCase

#   def test_ex1
#     mol = Chem.parse_smiles("OCC(CC)CCC(CN)CN")
#     assert_equal("CCC(CO)CCC(CN)CN", mol.to_cansmi)
#   end

#   def test_naphthalene
#     mol = Chem.parse_smiles("C1=CC=C2C=CC=CC2=C1")
#     cansmi = mol.to_cansmi
#     assert_block do
#       "C1=CC=C2C=CC=CC2=C1" == cansmi or
#         "C1=CC2=CC=CC=C2C=C1" == cansmi
#     end
#     p cansmi
#   end

#   def test_cubane
#     mol = Chem.parse_smiles("C12C3C4C1C5C4C3C25")
#     assert_equal("C12C3C4C1C5C2C3C45", mol.to_cansmi)
#     p mol.to_cansmi
#   end

#   def test_melphalan
#     mol = Chem.parse_smiles("C1=CC(=CC=C1CC(C(=O)O)N)N(CCCl)CCCl")
#     assert_equal("C1=CC(=CC=C1CC(C(=O)O)N)N(CCCl)CCCl", mol.to_cansmi)
#   end
#   def test_hypericin
#     mol = Chem.open_mol(File.join($data_dir, "hypericin.mol"))
#     assert_equal("CC1=CC(=O)C2=C(C3=C(C=C(C4=C3C5=C6C7=C(C1=C25)C(=CC(=O)C7=C(C8=C(C=C(C4=C86)O)O)O)C)O)O)O", mol.to_cansmi)
#   end

  def test_true
    assert(true)
  end
  
end
