#
# = chem/utils/ullmann.rb - Subgraph isomorphism
#
# Author::	Nobuya Tanaka <t@chemruby.org>
#		
# Copyright::	Copyright (c) 2005, 2006 ChemRuby project
#
# $Id: ullmann.rb 180 2006-04-19 08:52:15Z tanaka $
#

$ARC = 4 # for 32-bit computer

ARCH = 32

module Chem

  module Molecule

    def match_by_ullmann(target, &block)
      require 'subcomp'
      Chem.match_by_ullmann(self, target, &block)
    end

    def match(target, &block)
      ary = nil

      if block_given?
        ary = match_by_ullmann(target){ |i, j|
          yield(self.nodes[i], target.nodes[j])
        }
      else
        ary = match_by_ullmann(target)
      end

      ret = []
      ary.each do |a|
        hash = {}
        a.each_with_index do |i, j|
          hash[nodes[j]] = target.nodes[i]
        end
        hash
        ret << hash
      end
      ret
    end

    def typ_str
      nodes.collect{|atom| atom.atomic_number}.pack("l*")
    end

    def adjacent_index
      nodes.inject([]) do |ret, node|
        ary = ret[nodes.index(node)] = []
        adjacent_to(node).each do |bond, ad_node|
          ary << nodes.index(ad_node)
        end
        ret
      end
    end

    def bit_mat
      bm = BitMatrix.new(nodes.length, nodes.length)
      if edges.length == 0
        bm.has_matrix = false
      else
        adj = {}
        nodes.each do |node|
          adj[node] = []
          adjacent_to(node).each do |bond, to|
            adj[node] << to
          end
        end

        nodes.each_with_index do |atom1, idx1|
          ary = []
          nodes.each_with_index do |atom2, idx2|
            if adj[atom1].include?(atom2)
              bm.set(idx1, idx2)
            end
          end
        end
      end
      bm
    end

  end

  class BitMatrix

    attr_reader :height, :widht, :n_bytes
    attr_accessor :has_matrix

    def initialize(height, width)
      @height = height
      @width  = width
      @n_bytes = (width - 1) / ARCH + 1
      @bits = []
      height.times do |n|
        @bits[n] = []
        @n_bytes.times do |m|
          @bits[n][m] = 0
        end
      end
      @has_matrix = true
    end

    def set(row, col)
      @bits[row][col / ARCH] += (1 << (col % ARCH))
    end

    def to_s
      s = "     "
      @width.times{|n| s << "%d" % (n % 10)}
      s << "\n"
      @bits.each_with_index do |ary, idx|
        s << "%3d  " % idx
        ary.each_with_index do |a, idx2|
          s << bit_to_str(a, (idx2 == @n_bytes - 1) ? (@width % ARCH) : ARCH)
        end
        s << "\n"
      end
      s
    end

    def bit_str
      @bits.flatten.pack("L*")
    end

    def bit_to_str bits, num
      s = ""
      num.times do |n|
        s << (((1 << n) & bits != 0) ? "*" : ".")
      end
      s
    end
    private :bit_to_str

  end

  # Database Specification
  # * idx file 
  # 32 bit : n_bytes
  class CompoundDB

    def initialize(name)
      @current_id = 0
      @mat = File.open(name + ".mat", "w")
      @idx = File.open(name + ".idx", "w")
      @typ = File.open(name + ".typ", "w")
    end

    def store(mol)
      bm = mol.bit_mat
      @current_id += 1

      if bm.has_matrix
        @idx.print [bm.height, bm.n_bytes, @mat.tell, 0].pack("l*")
        @mat.print bm.bit_str
      else
        @idx.print [bm.height, bm.n_bytes, @mat.tell, -1].pack("l*")
      end
      @typ.print mol.typ_str
      @current_id
    end

    def close
      @idx.print [-1, -1, -1].pack("l*")

      @mat.close
      @idx.close
      @typ.close
    end

  end

end

