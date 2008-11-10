# $Id: test_mdl.rb 84 2005-12-01 10:01:04Z tanaka $

# Tests to ensure functionality

require 'all'
require 'test/unit'
require 'type_test'
require 'ctab_test'
require 'coord_test'

require 'chem'

class SybylTest < Test::Unit::TestCase

  include Chem::TypeTest
  include Chem::CtabTest
#  include Chem::CoordTest

  def setup
    (@entries = []).push(Chem.open_mol($data_dir + "hypericin.mol2"))
    @parser = Chem::Sybyl::SybylMolecule
    @file_type = Chem::Type::SybylType
  end

  def test_counts_line
    mol = @entries[0]
    assert_equal(67, mol.n_atoms)
    assert_equal(70, mol.n_bonds)
  end

  def test_atom
    atom = Chem::Sybyl::SybylAtom.new("     60 H60        -4.920329   -2.301872    1.618476 H         1 <1>         0.024481 ")
    assert_equal(:H, atom.element)
    assert_in_delta(-4.920329, atom.x, 0.0001)
    assert_in_delta(-2.301872, atom.y, 0.0001)
    assert_in_delta( 1.618476, atom.z, 0.0001)
    atom2 = Chem::Sybyl::SybylAtom.new("      1 C1         -3.262565   -0.588014   -0.082185 C.3       1 <1>        -0.020001 ")
    assert_equal(:C, atom2.element)
  end

  def test_save_sybyl_atom
    atom = Chem::SkeletonAtom.new
    atom.x = -3.262565
    atom.y = -0.588014
    atom.z = -0.082185

    assert_equal("      1", atom.to_sybyl[0..7])
#    assert_equal("", atom.to_sybyl[
  end

  def test_bond
    bond = Chem::Sybyl::SybylBond.new("     1   10   13 1    ")
    assert_equal(10, bond.b)
    assert_equal(13, bond.e)
    assert_equal( 1, bond.v)
  end

  def test_mol
    # assert_equal((0..66).to_a, @entries[0].match_by_ullmann(@entries[0]))
  end

end
