require 'test/all'

class KCFGlycanTest < Test::Unit::TestCase

  def test_true
    Chem.open_mol($data_dir + "G00147.kcf")
#    assert(false)
  end

end
