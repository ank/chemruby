#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_chem.rb 127 2006-02-03 02:47:57Z tanaka $
#

require 'test/all'

class ChemTest < Test::Unit::TestCase

  def test_auto_detection
    Chem.open_mol($data_dir + "cyclohexane.mol")
#    Chem.open_mol($data_dir + "cyclohexane.mol", :mol)
    assert_raise(NotImplementedError){Chem.open_mol($data_dir + "cyclohexane.no_such_format")}
  end

end
