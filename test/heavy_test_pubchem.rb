# $Id: heavy_test_pubchem.rb 65 2005-10-25 17:17:36Z tanaka $

require 'test/all'

class PubChemTest < Test::Unit::TestCase

  def test_fetch
    mol = Chem.parse_smiles("CCCCC")
    entries = mol.search_pubchem
  end

  def test_false
    assert(true)
  end

end
