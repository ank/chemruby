#
# graph.rb - Graph
#
#   Copyright (C) 2005, 2006 TANAKA Nobuya <t@chemruby.net>
#
# $Id: graph.rb 61 2005-10-12 09:17:39Z tanaka $
#


require 'graph/morgan'
require 'graph/cluster'
require 'graph/utils'

module Graph

  attr_accessor :nodes, :edges, :adjacencies

  def each
    nodes.each do |atom|
      yield atom
    end
  end

  def adjacent_to(atom)
    if @adjacencies == nil
      @adjacencies = Hash.new
      edges.each do |bond, atom_a, atom_b|
        (@adjacencies[atom_a] ||= []).push([bond, atom_b])
        (@adjacencies[atom_b] ||= []).push([bond, atom_a])
      end
    end
    @adjacencies[atom] ||= []
    @adjacencies[atom]
  end

  def adjacencies(atom)
    @adjacencies[atom] ||= []
    @adjacencies[atom]
  end
end
