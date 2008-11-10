# $Id: test_smiles.rb 124 2006-01-16 09:15:20Z tanaka $
require 'chem/db/smiles'

require 'test/all'

require 'test/ctab_test'

class SmilesSampleTest < Test::Unit::TestCase

  include Chem::CtabTest

  def setup
    @entries = []

    [
      "C", 
     "[Au]", 
      "[235U]",
      "CC",
      "CCC",
      "C=O",
      "C=CC=C",
      "C#N",
      "CC(C)C(=O)O",
      "O=Cl(=O)(=O)[O-]", # Cl(=O)(=O)(=O)[O-]
      "CCCC(C(=O)O)CCC", # 4-heptanoic acid

      # Ring
     "C1CCCCC1", # Cyclohexane
      "C1=CCCCC1", # cyclohexene
      "c12c(cccc1)cccc2", # naphthalene
      "c1ccccc1c2ccccc2", # biphenyl 
      "C12C3C4C1C5C4C3C25", # Cubane

      # Isotopic specification
      "[C]", # elemental carbon
      "[12C]", # elemental carbon-12
      "[13C]", # elemental carbon-13
      "[13CH4]", # C-13 methane

      # Specifying double-bond configuration
      'F/C=C/F', # trans-difluoroethene
      'F\C=C\F', # trans-difluoroethene
      'F/C=C\F', # cis-difluoroethene
      'F\C=C/F', # cis-difluoroethene

      # Specifying tetrahedral chirality
      "N[C@@H](C)C(=O)O", # L-alanine
      "N[C@H](C)C(=O)O", # D-alanine
      "O[C@H]1CCCC[C@H]1O", # cis-resorcinol
      "C1C[C@H]2CCCC[C@H]CC1", #cis-decaline

      # http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=043383,niaid
      "C1=CC2=C3C(=C1)C=CC4=C3C(=CC5=C4[C@H]([C@H](C=C5)O)O)C=C2",
      "NC(Cc1c[nH]c2cc[se]c12)C(O)=O", # pointed out by Dr. ktaz
      "S=[Co]", 
    ].each do |smiles|
      @entries.push(Chem.parse_smiles(smiles))
    end
#       mass : NUMBER
  end
end

class SmilesTest < Test::Unit::TestCase

  def test_cubane
    Chem.parse_smiles("C12C3C4C1C5C2C3C45")
  end

  def test_atom_types
    [
      ["H"      , {:element => :H}],
      ["C"      , {:element => :C,  :is_aromatic => false, :mass => 12.0107}],
      ["c"      , {:element => :C,  :is_aromatic => true}],
      ["[se]"     , {:element => :Se, :is_aromatic => true}],
      ["[235U]" , {:element => :U,  :mass => 235.0}],
      ["[nH]"   , {:element => :N,  :is_aromatic => true}], # Hydrogen
      ["[OH3+]" , {:element => :O,  :hydrogen_count => 3}],
      ["[Fe2+]" , {:element => :Fe, :charge => 2}],
      ["[Fe++]" , {:element => :Fe, :charge => 2}],
      ["[13CH4]", {:element => :C,  :hydrogen_count => 4, :mass => 13}],
      ["[2H]"   , {:element => :H,  :mass => 2}],
#      ["[C@H]"   , {:element => :H}],
#      ["[C@@H]"   , {:element => :H}],
    ].each do |sm, prop|
      mol = SMILES(sm)
      prop.each do |key, val|
        assert_equal(val, mol.nodes[0].send(key))
      end
    end
  end

  def test_co
    # Not cobalt
    comp = Chem.parse_smiles("O=CO").composition
    assert_equal(2, comp[:O])
    assert_equal(1, comp[:C])
  end

end
