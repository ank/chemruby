


class MDLTest < Test::Unit::TestCase

  def test_false
    mol = SMILES("CCC")
    mol.assign_2d_geometry
  end

end
