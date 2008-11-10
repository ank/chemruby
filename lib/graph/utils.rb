
module Graph

  # Returns Terminal Nodes
  def terminal_nodes
    self.nodes.find_all{|node| self.adjacent_to(node).length == 1}
  end
end
