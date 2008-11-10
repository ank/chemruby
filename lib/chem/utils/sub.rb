#
# = chem/utils/sub.rb - Subgraph
#
# Author::	Nobuya Tanaka <t@chemruby.org>
#		
# Copyright::	Copyright (c) 2005, 2006 ChemRuby project

module Chem
  module Molecule

    def induced_sub ary
      sub = deep_dup
      (sub.nodes - ary).each do |node|
        sub.delete(node)
      end
      sub
    end

    def connected?
      traversed = []
      start = @nodes[0]
      traversed << start
      dfs(start) do |from, to|
        traversed << to
      end
      traversed.length == @nodes.length
    end

    # divide compounds by connectivity
    # e.g. washing salts.
    def divide
      traversed = []
      start = @nodes[0]
      divided_compound = []

      while traversed.length != @nodes.length
        part = []
        traversed << start
        part << start
        dfs(start) do |from, to, bond|
          unless part.include?(to)
            traversed << to
            part << to
          end
        end

        start = @nodes.find{|node| !traversed.include?(node)}
        divided_compound << induced_sub(part)
      end
      divided_compound
    end

    def delete_bond(bond)
      @edges.delete(bond)
      @adjacencies.each do |v, k|
        k.delete_if{ |b, atom_a, atom_b| bond == b}
      end
    end

    def delete(atom)
      @nodes.delete(atom)
      adjacent_to(atom).each do |adj_edge, adj_node|
        @edges.delete_if{|bond, atom_a, atom_b| bond == adj_edge}
      end
    end

    def deep_dup
      ret = dup
      ret.nodes = @nodes.dup
      #ret.adjacencies = @adjacencies.dup if @adjacencies
      ret.edges = @edges.dup
      ret
    end

    def - (other)
      if other.instance_of?(Array)
        induced_sub(@nodes - other)
      else
        induced_sub(@nodes - other.nodes)
      end
    end

  end
end
