#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_adj.rb 127 2006-02-03 02:47:57Z tanaka $
#

require 'test/all'

require 'chem'

class AdjTest < Test::Unit::TestCase
  
  def setup
    @cyclohexane = Chem.open_mol($data_dir + "cyclohexane.mol")
  end

  def test_adjacent_to
    @cyclohexane.each do |node|
      assert_equal(@cyclohexane.adjacent_to(node).length, 2)
    end
  end

  def test_dup
    cyclo = @cyclohexane.deep_dup
    cyclo.delete(cyclo.nodes[0])
    assert_equal(5, cyclo.nodes.length)
    assert_equal(6, @cyclohexane.nodes.length)
  end

  def est_delete#!!!BUG
    assert_equal(6, @cyclohexane.nodes.length)
    adj = []
    @cyclohexane.adjacent_to(@cyclohexane.nodes[0]).each do |bond, atom|
      adj.push(atom)
    end

    @cyclohexane.delete(@cyclohexane.nodes[0])

    adj.each do |atom|
      assert_equal(1, @cyclohexane.adjacent_to(atom).length)
    end

    @cyclohexane.nodes.each do |atom|
      if !adj.include?(atom)
        assert_equal(2, @cyclohexane.adjacent_to(atom).length)
      end
    end

    assert_equal(@cyclohexane.nodes.length, 5)
    assert_equal(@cyclohexane.edges.length, 4)
  end

end
