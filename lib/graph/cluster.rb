
module Graph

  def clustering_coefficient
    cc = {} # clustering coefficient
    @nodes.each do |node|
      c = 0
      adj = adjacent_to(node)
      adj_nodes = adj.collect{|e, n| n}
      adj.each do |ed, nd|
        adjacent_to(nd).each do |e, n|
          c += 1 if adj_nodes.include?(n)
        end
      end
      cc[node] = c
    end
    cc
  end

end
