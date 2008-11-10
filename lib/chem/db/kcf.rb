#
# 
# = chem/db/kcf.rb - KEGG Compound Function parser
#

module Chem

  module KEGG

    class ANumber

      def self.open filename
        @input = File.open(filename)
        KCFCorrespondence.new(@input)
      end

    end

    class KCFAtom

      include Atom
      attr_accessor :kcf_type, :atom_id, :next_atom

      def initialize line
        @line = line
        @next_atom = {}
      end

      def x ; @x || @x = @line[22...32].to_f ; end
      def y ; @y || @y = @line[32...42].to_f ; end
      def kcf_type ; @kcf_type || @kcf_type = @line[16...19].strip ; end

      def element ; @element || @element = @line[19...22].strip.intern ; end

      def atom_id ; @atom_id || @atom_id = @line[0...16].to_i ; end

    end

    class KCFBond

      include Bond
      attr_accessor :bond_id, :property

      def initialize line
        @line = line
      end

      def bond_id  ; @bond_id  ||= @line[0...16].to_i  ; end

      def v        ; @v        ||= @line[23...25].to_i ; end
      def property ; @property ||= @line[27..-1]       ; end

    end

    class KCF

      include Molecule
      include Enumerable

      def initialize input
        @nodes = []
        @edges = []
        hash = {}
        while ! /\/\/\//.match(line = input.readline)
          case line[0...12]
          when 'ENTRY       '
          when 'ATOM        '
            line.split[1].to_i.times do |n|
              atom = KCFAtom.new input.readline

              hash[atom.atom_id] = atom
              @nodes.push(atom)
            end
          when 'BOND        '
            line.split[1].to_i.times do |n|
              bond = KCFBond.new input.readline
              @edges.push([bond, hash[line[16...19].to_i], hash[line[19...23].to_i]])
            end
          end
        end
      end

      def KCF.open filename
        @input = File.open(filename)
        KCF.new(@input)
      end

    end

    class KeggReaction

      class ReactionEntry
        attr_accessor :entry, :name, :definition, :reactants, :products, :rpair, :ec, :comment, :pathway
        def initialize
          @comment = []
          @name = []
          @definition = []
        end
      end

      def initialize input
        @input = input
      end

      def KeggReaction.open filename
        KeggReaction.new(File.open(filename))
      end

      def each
        while ! @input.eof?
          entry = ReactionEntry.new
          state = :INITIAL
          while ! /\/\/\//.match(line = @input.readline)
            #case line[0...12]
            type = line[0...12]
            if 'ENTRY       ' == type
              entry.entry = line[12...-1]
            elsif 'NAME        ' == type || state == :NAME
              state = :NAME
              entry.name = line[12...-1]
            elsif 'DEFINITION  '  == type || state == :DEFINITION
              state = :DEFINITION
              entry.definition.push(line[12...-1])
            elsif 'EQUATION    ' == type
              ary = line[12...-1].split('<=>')
              entry.reactants = ary[0].split('+').collect{|mol| mol.strip}
              entry.products = ary[1].split('+').collect{|mol| mol.strip}
            elsif 'RPAIR       ' == type
              entry.rpair = line[12...-1]
            elsif 'ENZYME      ' == type
              entry.ec = line[12...-1].split('.').collect{|n| n.to_i}
            elsif 'COMMENT     ' == type || state == :COMMENT
              state = :COMMENT
              entry.comment.push(line[12...-1])
            elsif 'PATHWAY     ' == type || state == :PATHWAY
              state = :PATHWAY
            else
              puts "Error Unknown line : %s" % line
            end
          end
          yield entry
        end
      end
    end

    class KCFRXN
      def initialize reactant, product
        @reactant = reactant
        @product = product
        @matched_reactants = []
        @matched_products = []
        @nodes = []
      end

      def corresponds from, to
        @matched_reactants.push(@reactant.atoms[from])
        @matched_products.push(@product.atoms[from])
        @nodes.push(RXNNode.new(@reactant.atoms[from], @product.atoms[to]))
      end

      def setup_bonds
        @edges = []
        @reactant.atoms.each do |atom|
          if atom && ! @matched_reactants.member?(atom)
            @nodes.push(RXNNode.new(atom, nil))
          end
        end
        @product.atoms.each do |atom|
          if atom && ! @matched_products.member?(atom)
            @nodes.push(RXNNode.new(nil, atom))
          end
        end

        @reactant.bonds.each do |bond|
          bond.e.next_atom[bond.b] = bond
          bond.b.next_atom[bond.e] = bond
        end
        @product.bonds.each do |bond|
          bond.e.next_atom[bond.b] = bond
          bond.b.next_atom[bond.e] = bond
        end
        @nodes.each_with_index do |node, index|
          index.upto(@nodes.length - 1) do |n|
            r_edge = p_edge = nil
            if @nodes[n].reactant_node && @nodes[n].reactant_node.next_atom.has_key?(node.reactant_node)
              r_edge = @nodes[n].reactant_node.next_atom[node.reactant_node]
            end
            if @nodes[n].product_node && @nodes[n].product_node.next_atom.has_key?(node.product_node)
              p_edge = @nodes[n].product_node.next_atom[node.product_node]
            end
            if r_edge || p_edge
              edge = RXNEdge.new
              edge.reactant_edge = r_edge
              edge.product_edge = p_edge
              @edges.push(edge)
            end
          end
        end
        @edges.each do |edge|
          from = edge.reactant_edge ? edge.reactant_edge.multiplicity : 0
          to = edge.product_edge ? edge.product_edge.multiplicity : 0
          puts "%3d %3d" % [from, to]
        end
      end

      class RXNNode
        attr_reader :reactant_node, :product_node
        def initialize reactant, product
          @reactant_node = reactant
          @product_node = product
        end
      end
      class RXNEdge
        attr_accessor :product_edge, :reactant_edge
      end
    end

    class KCFCorrespondence

      attr_reader :compounds, :correspondence

      def initialize input
        @name = []
        @input = input
        @compounds = []
        @correspondence = {}
        parse(input)
      end

      def make_rxn dir
        reactant = KCF.open("#{dir}#{@compounds[0]}.kcf")
        product = KCF.open("#{dir}#{@compounds[1]}.kcf")
        rxn = KCFRXN.new(reactant, product)
        @correspondence.each do |k, corres|
          rxn.corresponds(corres[0][0], corres[1][0])
        end
        rxn.setup_bonds
      end

      def parse input
        while ! /\/\/\//.match(line = input.readline)
          case line[0...12]
          when 'ENTRY       '
            @no = /(\d+)/.match(line)[1].to_i
          when 'NAME        '
            @name.push(line[12...-1])
          when 'COMPOUND    '
            @compounds.push(line[12...-1])
          when 'TYPE        '
            @type = line[12...-1]
          when 'ALIGN       '
            @align = line[12...-1].to_i
            alignment_mode = true
          else
            ary = line[12...-1].split
            @correspondence[ary[0].to_i] = ary[1..2].collect{|e| a = e.split(':'); [a[0].to_i, a[1]]}
          end
        end
      end

    end

    module Atom
      attr_accessor :kcf_type, :kcf_prop

      # Returns KCF formatted line
      def kcf_line
        if @kcf_prop
          "%14d  %3s%2s %10.4f%10.4f #%s" % [@number, @kcf_type, @element, @x, @y, @kcf_prop]
        else
          "%14d  %3s%2s %10.4f%10.4f" % [@number, @kcf_type, @element, @x, @y]
        end
      end
    end

    module Bond
      attr_accessor :kcf_prop

      # Returns KCF formatted line
      def kcf_line
        if @kcf_prop
          "%13d  %4d%4d%2d #%s" % [@number, @b.number, @e.number, @multiplicity, @kcf_prop]
        else
          "%13d  %4d%4d%2d" % [@number, @b.number, @e.number, @multiplicity, @kcf_prop]
        end
      end

    end

    class KCFReader

      def KCFReader.open(file, &method)
        input = File.open(file, 'r')
        KCFReader.new.read(input, &method)
      end

      def read input, &method
        #       0.upto(2) do |m|
        #         0.upto(9) do |n|
        #           print n
        #         end
        #       end
        #       puts
        status = :NEW
        mol = KCFMolecule.new
        input.each do |line|
          case line[0..11]
          when /ANUMBER/
            mol.a_no = /A(\d+)/.match(line)[1].to_i
          when /ENTRY/
            entry = /C(\d+)/.match(line)[1].to_i
          when /ATOM/
            n_atoms = /(\d+)/.match(line)[1].to_i
            status = :ATOM
          when /BOND/
            n_bonds = /(\d+)/.match(line)[1].to_i
            status = :BOND
          when /\/\/\//
            if(method)
              yield mol
            end
            mol = KCFMolecule.new
            status = :NEW
          else
            case status
            when :ATOM
              atom = KCFAtom.new
              atom.number, atom.kcf_type, atom.element, atom.x, atom.y, = line[12..-1].scanf("%d%s%s%f%f%s")
              mol.atoms[atom.number] = atom
            when :BOND
              bond = KCFBond.new
              no, b, e, bond.multiplicity, prop = line[12..-1].scanf("%d%d%d%d%s")
              bond.b = mol.atoms[b]
              bond.e = mol.atoms[e]
              mol.bonds.push(bond)
            end
          end
        end
      end
    end

    class KCFMolecule

      include Molecule
      attr_accessor :a_no

      def KCFMolecule.write_kcf molecule
        n_atom = 1
        molecule.atoms.each do |k, atom|
          puts atom.kcf
          n_atom += 1
        end
        n_bond = 1
        molecule.bonds.each do |bond|
          #            1     2   1 1 #UP
          kcf.number = 48
          puts bond.kcf_line
          n_bond += 1
        end
      end

      def KCFMolecule.open file
        input = File.open(file, 'r')
        KCFMolecule.new.read(input)
      end

      def read input
        @entry = input.readline
        number_of_atom = input.readline.split[1].to_i
        1.upto(number_of_atom) do |n|
          atom = KCFAtom.new
          atom.number, atom.kcf_type, atom.element, atom.x, atom.y, = input.readline.scanf("%d%s%s%f%f%s")
          @atoms[atom.number] = atom
        end
        number_of_bond = input.readline.split[1].to_i
        1.upto(number_of_bond) do |n|
          bond = KCFBond.new
          no, b, e, bond.multiplicity, prop = input.readline.scanf("%d%d%d%d%s")
          bond.b = @atoms[b]
          bond.e = @atoms[e]
          @bonds.push(bond)
        end
        self
      end

    end
  end
end


