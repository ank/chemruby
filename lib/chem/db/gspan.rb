#
# = gspan.rb - IO modules for gSpan format
#
# Copyright::	Copyright (C) 2005-2006
#		Tadashi Kadowaki <kadowaki@kuicr.kyoto-u.ac.jp>
#		Nobuya Tanaka <tanaka@kuicr.kyoto-u.ac.jp>

$: << "/home/tanaka/proj/chemruby/lib/"
$: << "/home/tanaka/proj/chemruby/ext/"

require 'chem'

module Chem

  class GSpan

    FIRST_NODE = /\((\d+)\)/
    REG_NODE   = /\s*(\d+)\s*\((\d*)(f|b)(\d+)\)/

    # Parse one-lined gSpan formatted string and return
    # molecule object.
    def self.parse str, name = ""
      mol = GSpanMolecule.new
      mol.name = name

      first_atom = GSpanAtom.new(FIRST_NODE.match(str)[1].to_i)
      mol.nodes.push(first_atom)

      str.scan(REG_NODE) do |s|
        bond = GSpanBond.new( s[0].to_i )
        if s[2] == 'f'
          from_atom = mol.nodes[ s[1].to_i ]
          to_atom = GSpanAtom.new( s[3].to_i )
          mol.nodes.push(to_atom)
        else # s[2] == 'b'
          from_atom = mol.nodes[ mol.nodes.size-1 ]
          to_atom = mol.nodes[ s[3].to_i ]
        end
        mol.edges.push([bond, from_atom, to_atom ])
      end

      mol
    end

    # Save molecule as gSpan formatted file.
    # Example :
    #   Chem::GSpan.save(mols , "filename") # mols : an array of molecules
    def self.save mols, filename, params = {}
      open(filename, "w") do |out|
        mols.each_with_index do |mol, mol_idx|
          out.puts "t # #{mol_idx} -1 #{mol.name}"
          mol.nodes.each_with_index do |node, idx|
            out.puts "v %d %d" % [idx, node.atomic_number]
          end
          mol.edges.each_with_index do |(bond, node1, node2), idx|
            out.puts "e %d %d %d" % [mol.nodes.index(node1), mol.nodes.index(node2), bond.v]
          end
          out.puts
        end
        
      end
    end

  end

  # Concrete class of gSpan molecule
  class GSpanMolecule

    include Molecule
    include Enumerable

    def initialize
      @nodes = []
      @edges = []
    end

  end

  class GSpanAtom

    include Atom

    def initialize element
      @element = Number2Element[element]
    end

    def self.parse_line line
      self.new(line.split[2].to_i)
    end

  end

  class GSpanBond

    include Bond

    def initialize v
      @v = v
    end
    
  end

  def self.parse_gspan file
    t = "t"[0]
    v = "v"[0]
    e = "e"[0]

    mols = []
    mol = GSpanMolecule.new

    open(file).each do |line|
      case line[0]
      when t
        mol = GSpanMolecule.new
        mols.push(mol)
      when v
        mol.nodes.push(GSpanAtom.parse_line(line))
      when e
        ary = line.split
        node1 = mol.nodes[ary[1].to_i]
        node2 = mol.nodes[ary[2].to_i]
        mol.edges.push([GSpanBond.new(ary[3].to_i), node1, node2])
      else
      end
    end
    mols
  end


end
