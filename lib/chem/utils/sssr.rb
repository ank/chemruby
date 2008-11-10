#!/usr/bin/ruby

module Chem
  class Ring
  end

  module Molecule
    # J. Chem. Inf. Comput. Sci. 1996, 36, 986-991
    # John Figueras
    # Ring Perception Using Breadth-First Search

    # J. Chem. Inf. Comput. Sci. 1994, 34, 822-831
    # Renzo Balducci and Robert S. Pearlman
    # Efficient Exact Solution of the Ring Perception Problem
    #

    def find_smallest_ring root
      path = {}
      path[root] = [root]

      bfs(root) do |from, to|
	if visit = !path.keys.include?(to)
	  path[to] = path[from].clone
	  path[to].push(to)
	elsif path[from][-2] != to
	  if 1 == (path[from] & path[to]).length
	    return path[from] + path[to][1..-1].reverse
	  end
	end
	visit
      end
    end

    # Fix me! This is not sufficient
    def canonical_ring ring
      ring.sort{|a, b| nodes.index(a) <=> nodes.index(b)}
    end

    # Returns Smallest Set of Smallest Ring
    def find_sssr

      fullSet = nodes.dup
      trimSet = []
      rings = []
      mol = {}

      nodes.each do |node|
        mol[node] = []
        adjacent_to(node).each do |bond, atom|
          mol[node] << atom
        end
      end

      loop do
	nodesN2 = []
	smallest_degree = 10
	smallest = nil

	mol.each do |k, a|
	  case a.length
	  when 0
	    mol.delete(k)# Is this OK?
	    trimSet.push(k)
	  when 2
	    nodesN2.push(k)
	  end
	  if a.length > 0 && a.length < smallest_degree
	    smallest = k
	    smallest_degree = a.length
	  end
	end

	case smallest_degree
	when 1
	  trim(mol, smallest)
	when 2
	  nodesN2.each do |k|
	    ring = find_smallest_ring(k)
            if ring && !rings.include?(canonical_ring(ring))
              rings.push(canonical_ring(ring))
            end
	  end
	  nodesN2.each do |k|
	    trim(mol, k)
	  end
	when 3
	  ring = find_smallest_ring(smallest)
	  trim(mol, smallest)
	end

	break if mol.length  == 0
      end
      rings
    end

    def trim mol, smallest
      if mol.length > 0 && mol.include?(smallest)
	mol[smallest].each do |n|
	  mol[n] = mol[n] - [smallest]
	  mol.delete(smallest)
	  mol.delete(n) if mol[n].length == 0
	end
      end
    end
    private :trim

  end
end

