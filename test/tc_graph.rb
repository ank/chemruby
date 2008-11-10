class DummyGraph
  include Graph
end

class GraphTest < Test::Unit::TestCase

  def test_to_mdl
    graph = DummyGraph.new
    graph.nodes = [1, 2, 3]
    graph.edges = [[0, 1, 2], [1, 2, 3]]

    assert_equal([1, 3], graph.terminal_nodes)
  end

end
