
module Chem
  module Molecule
    # Breadth first search solves steps and path to the each node and forms
    # a tree contains all reachable vertices from the root node.

    def breadth_first_search(root = @nodes[0])

      queue = [ root ]

      traversed = []

      while from = queue.shift
	adjacent_to(from).each do |bond, to|
          next if traversed.include?(bond)
          traversed.push(bond)
          queue.push(to) if yield(from, to)
	end
      end
    end

    alias :bfs :breadth_first_search

    def depth_first_search(from = @nodes[0], traversed = [], &block)
      adjacent_to(from).each do |bond, to|
        next if traversed.include?(bond)
        traversed.push(bond)
        yield(from, to, bond)
        depth_first_search(to, traversed, &block)
      end
    end

    alias :dfs :depth_first_search

  end
end

