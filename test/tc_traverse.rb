# $Id: test_traverse.rb 65 2005-10-25 17:17:36Z tanaka $

require 'test/all'

class TraverseTest < Test::Unit::TestCase

  def setup
    @cyclohexane = Chem.open_mol($data_dir + 'cyclohexane.mol')
  end

  def test_bfs
    i = 0
    @cyclohexane.bfs do |from, to|
      i += 1
      # Block should return true if you want to continue traversing this branch!
      true
    end
    assert_equal(i, 6)
  end

  def test_dfs
    i = 0
    @cyclohexane.dfs do |from, to, bond|
      i += 1
    end
    assert_equal(i, 6)
  end

end
