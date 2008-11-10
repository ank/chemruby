#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_eps.rb 132 2006-02-04 19:16:50Z tanaka $
#

require 'test/unit'

require 'test/all'

require 'chem'

class EpsTest < Test::Unit::TestCase

  def setup
    @mol = Chem.open_mol($data_dir + 'test.mol')
  end

  def test_eps
#    assert_nothing_raised(Chem.save(mols, File.join(%w(temp temp.eps))))
  end

end
