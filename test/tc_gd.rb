require 'chem'

class GDTest < Test::Unit::TestCase

  def test_gd
    mol = Chem.open_mol($data_dir + "cyclohexane.mol")
  end
end
