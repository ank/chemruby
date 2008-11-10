#
# chem/db/mdl.rb - MDL molfile format class
#

require 'date'

module Chem

  module Molecule

    MDLCountLineFormat = "%3d%3d%3d%3d%3d%3d%3d%3d%3d  0999 V2000"
    MDLHeaderLine2Format = "%2s%8s%02d%02d%02d%02d%02d"

    def save_as_mdl(filename)
      File.open(filename, "w") do |out|
        now = DateTime.now
        out.puts 
        out.puts MDLHeaderLine2Format % [
          "  ",
          "ChemRuby",
          now.month,
          now.mday,
          now.year % 2000,
          now.hour,
          now.min
        ]
        out.puts filename
        out.puts MDLCountLineFormat % [nodes.length, edges.length, 0, 0, 0, 0, 0, 0, 0]
        nodes.each do |node|
          out.puts node.to_mdl
        end
        edges.each do |edge, atom1, atom2|
          out.puts edge.to_mdl(nodes.index(atom1) + 1, nodes.index(atom2) + 1)
        end
        out.puts "M  END"
      end
    end

  end

  module Atom

    MDLAtomLineFormat = "%10.4f%10.4f%10.4f %2s%3d%3d%3d%3d%3d%3d%3d%3d%3d%3d%3d%3d"

    def to_mdl(mapping = 0)
      self.x ||= 0
      self.y ||= 0
      self.z ||= 0
      MDLAtomLineFormat % [x, y, z, element, 0, 0, 0, 0, 0, 0, 0, 0, 0, mapping, 0, 0]
    end

  end

  module Bond

    def to_mdl(from, to)
      "%3d%3d%3d%3d      " % [from, to, v, 0]
    end

  end

  module Reaction

#     def to_mdl_rxn
#       return # fix me
# #      out = STDOUT
#       out.puts "$RXN"
#       out.puts
#       out.puts "ISIS     112620051015"
#       out.puts
#       out.puts "%3d%3d" % [@reactants.length, @products.length]
#       @reactants.each{ |mol| output_mdl_mol(mol, out)}
#       @products.each{ |mol| output_mdl_mol(mol, out)}
#     end

    private
    def output_mdl_mol(mol, out)
      out.puts "$MOL"
      mol.nodes.each do |node|
        out.puts node.to_mdl(10)
      end
      out.puts "M  END"
    end

  end

  module MDL

    class MDLAtom

      include Atom

      Stereo = {
        0 => :not_stereo,
        1 => :odd,
        2 => :even,
        3 => :either
      }

      attr_accessor :number

      def initialize line  ; @line              = line                       ; end

      # Returns atomic symbol
      def element          ; @element         ||= @line[30..32].strip.intern ; end
      def x                ; @x               ||= @line[0..9].to_f           ; end
      def y                ; @y               ||= @line[10..19].to_f         ; end
      # Coordinates for z-axis
      def z                ; @z               ||= @line[20..29].to_f         ; end
      # Difference from mass in periodic table.
      def mass_difference  ; @mass_difference ||= @line[33..35]              ; end
      def charge           ; @charge          ||= @line[36..38].to_i         ; end
      def stereo_parity    ; @stereo_parity   ||= @line[39..41].to_i         ; end
      def hydrogen_count   ; @hydrogen_count  ||= @line[42..44].to_i         ; end
      def stereo_care_box  ; @stereo_care_box ||= @line[45..47].to_i         ; end

      def valence          ; @valence         ||= @line[48..50].to_i         ; end
      def h0_designator    ; @h0_designator   ||= @line[51..53].to_i         ; end
      # 54..56 Not used
      # 57..59 Not used
      def mapping          ; @mapping         ||= @line[60..62].to_i         ; end
      def inversion        ; @inversion       ||= @line[63..65].to_i         ; end
      def exact_charge     ; @exact_charge    ||= @line[66..68].to_i         ; end

    end

    class MDLBond

      include Bond

      Stereo = {
        0 => :not_stereo,
        1 => :up,
        3 => :cis_trans,
        4 => :either,
        6 => :down
      }

      BondType = {
        1 => :single,
        2 => :double,
        3 => :triple,
        4 => :aromatic,
        5 => :single_or_double,
        6 => :single_or_aromatic,
        7 => :double_or_aromatic,
        8 => :any
      }

      ReactingCenter = {
        0  => :unmarked,
        1  => :center,
        -1 => :not,
        2  => :no_change,
        4  => :made_or_broken,
        8  => :order_changes
      }

      Topology = {
        0 => :either,
        1 => :ring,
        2 => :chain
      }

      def initialize(line)  ; @line              = line                                       ; end

      def v                ; @v               ||= @line[6..8].to_i                           ; end

      def topology         ; @topology        ||= Topology[@line[13..15].to_i]               ; end
      def reacting_center  ; @reacting_center ||= ReactingCenter[@line[16..18].to_i]         ; end
      def stereo           ; @stereo          ||= Stereo[@line[9..11].to_i]                  ; end
      def bond_type        ; @v               ||= BondType[self.v]                           ; end

    end

    module MdlMolParser

      attr_reader :filename
      def open(filename)
        @filename = filename
        input = File.open(filename)
        parse(input)
      end

      def entry
        @title
      end
      alias name entry

      attr_reader :mol_name

      def program_name ; @program_name ||= @header_line2[2..9] end

      def date_time
        year_last_two = @header_line2[14..15].to_i
        year = year_last_two + (year_last_two > 80 ? 1900 : 2000)
        @date ||= DateTime.new(
                               year,
                               @header_line2[10..11].to_i,
                               @header_line2[12..13].to_i,
                               @header_line2[16..17].to_i,
                               @header_line2[18..19].to_i)
      end

      def dimensional_codes
        @dimensional_codes ||=  @header_line2[20..21]
      end

      def parse(input)
        @mol_name = input.readline.chop
        @header_line2 = input.readline.chop
        raise MDLException if @comment = input.readline == nil
        line = input.readline
        n_atom = line[0..2].to_i
        n_bond = line[3..5].to_i

        if 0 > n_atom or 999 < n_atom or 0 > n_bond or 999 < n_bond
          raise "counts line format error"
        end

        n_atom.times do |n|
          mol = MDLAtom.new(input.readline)
          mol.number = n + 1
          @nodes.push(mol)
        end

        n_bond.times do |n|
          line = input.readline
          b = MDLBond.new line
          b_n = line[0..2].to_i
          e_n = line[3..5].to_i
          if (b_n > n_atom || b_n < 1 || e_n > n_atom || e_n < 1)
            p line
            raise "MDL bond line format error"
          end

          @edges.push([b, @nodes[b_n - 1], @nodes[e_n - 1]])
        end
        input.each do |line|
          break if /M  END/.match(line)
        end
        self
      end
    end

    class MdlMolecule
      
      include Molecule
      include Enumerable
      include MdlMolParser

      attr_reader :nodes, :edges

      def initialize
        @nodes = []
        @edges = []
      end

      def self.parse_io(input)
        mol = MdlMolecule.new
        mol.parse input
      end

      def self.parse(file)
        mol = MdlMolecule.new
        input = open(file)
        mol.parse input
      end

    end

    class RxnAtom
      include Atom
#      attr_accessor :reactant, :product

      def reactant=(rct)
        @reactant = @representative = rct
      end

      def method_missing(name, *args)
        if @representative.respond_to?(name)
          @representative.send(name, *args)
        else
          super(name, *args)
        end
      end
      

      def product=(prd)
        @product = prd
        @representative = prd unless @representative
      end

      def x       ; @representative.x       ; end
      def y       ; @representative.y       ; end
      def element ; @representative.element ; end

    end

    class RxnBond
      include Bond
      attr_accessor :reactant, :product
      attr_reader   :v

      def v
        if @reactant and @product
          return @product.v - @reactant.v
        elsif @reactant
          return - @reactant.v
        else
          return @product.v
        end
      end

    end

    class MdlReaction

      include Molecule
      include Reaction
      include Enumerable

      attr_reader :nodes, :edges

      def initialize
        @nodes = []
        @edges = []
        @reactants = []
        @products  = []
      end

      attr_reader :filename
      def open_rxn(filename)
        @filename = filename
        input = File.open(filename)
        n_reactants, n_products = parse_header(input)
        read_mol(input, n_reactants, @reactants, @r_atoms = {})
        read_mol(input, n_products,  @products,  @p_atoms = {})
        construct
        self
      end

      private
      def construct
        @p2r = {}
        @r2p = {}
        (@r_atoms.keys + @p_atoms.keys).each do |k|
          ratom = RxnAtom.new
          ratom.reactant = @r_atoms[k]
          ratom.product  = @p_atoms[k]
          @p2r[@p_atoms[k]] = @r_atoms[k]
          @r2p[@r_atoms[k]] = @p_atoms[k]
          @nodes.push(ratom)
        end
        get_edge_hash(@reactants, r_edge_hash = {})
        get_edge_hash(@products,  p_edge_hash = {})
        already = []
        @reactants.each do |mol|
          mol.edges.each do |edge, atom1, atom2|
            bond = RxnBond.new
            bond.reactant = edge
            if @r2p[atom1] and @r2p[atom2]
              bond.product = p_edge_hash[[@r2p[atom1], @r2p[atom2]].sort_by{|a| a.number}]
              already.push(bond.product)
            end
            @edges.push(bond)
          end
        end
        @products.each do |mol|
          mol.edges.each do |bond, atom1, atom2|
            next if already.include?(bond)
            r_bond = RxnBond.new
            r_bond.product = bond
            @edges.push([r_bond, atom1, atom2])
          end
        end
      end

      private
      def get_edge_hash(mols, hash)
        mols.each do |mol|
          mol.edges.each do |edge, atom1, atom2|
            hash[[atom1, atom2].sort_by{|a| a.number}] = edge
          end
        end
      end

      private 
      def read_mol(input, n, mols, atoms)
        n.times do
          loop do
            line = input.readline # $MOL
            break if /\$MOL/.match(line)
          end
          mol = MdlMolecule.parse_io(input)
          mol.nodes.each do |a|
            next if a.mapping == 0
            atoms[a.mapping] = a
          end
          mols.push mol
        end
      end

      private
      def parse_header(input)
        4.times{|n| input.readline}
        input.readline.split.collect{|n| n.to_i}
      end

    end

    module RDFParser
      def initialize(input)
      end
    end

  end

end

