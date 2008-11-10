require 'chem/molecule'

module Chem
  class PdbDic
    class PdbDicAtom < Atom
      attr_reader :atom_id, :neighbor
      def initialize atom_id
        @bonds = []
        @neighbor = []
        @atom_id = atom_id
        set_element
      end
      def set_element
        # Heuristically set element. Any idea?
        case @atom_id.gsub(/(\d|[*'\"])/, '').upcase
        when /S/
          @element = 'S'
        when 'B'
          @elmenet = 'B'
        when /^BR/
          @element = 'Br'
        when /^MO/
          @element = 'MO'
        when /^W/
          @element = 'W'
        when /^I/
          @element = 'I'
        when /CL/
          @element = 'Cl'
        when /^A?B?C/
          @element = 'C'
        when /^A?B?H/
          @element = 'H'
        when /^A?N/
          @element = 'N'
        when /^A?O/
          @element = 'O'
        when /^A?P/
          @element = 'P'
        when /^F/
          @element = 'F'
        else
          puts @atom_id
        end
      end
    end
    class PdbDicBond < Bond
      attr_accessor :v
    end
    class PdbDicMolecule < Molecule
      attr_reader :atoms, :bonds
      def initialize
        @atoms = {}
        @bonds = []
      end
    end

    attr_reader :mols
    def initialize file, &block
      @mols = {}
      parse(file, &block)
    end

    def parse file, &block
      i = 0
      @input = File.open(file, 'r')
      res = nil
      while !@input.eof?
        line = @input.readline
        case line
        when /^RESIDUE/
          mol = PdbDicMolecule.new
          res = line.split[1]
          @mols[res] = mol
#           if line.split[1] == 'ACY'
#             puts 'Found ACY'
#             exit
#           end
#          puts "'%s'" % line[0..5]
        when /^CONECT/
          atom = mol.atoms[line[11..15].strip] ||= PdbDicAtom.new(line[11..15].strip)
          line[20..-1].chop.split.each do |atom_id|
            if ! mol.atoms[atom_id]
              atom2 = PdbDicAtom.new(atom_id)
              mol.atoms[atom_id] = atom2
              bond = PdbDicBond.new
              bond.b = atom
              bond.e = atom2
              bond.v = 1
              mol.bonds.push(bond)
            end
          end
        when "\n"
          mol.bonds.each do |bond|
            bond.b.neighbor.push(bond.e) if ! bond.b.neighbor.include?(bond.e)
            bond.e.neighbor.push(bond.b) if ! bond.e.neighbor.include?(bond.b)
          end
#          i += 1
          if block
            yield res, mol
          end
          return if i >= 100
        else
#          puts line
        end
      end
    end
    def PdbDic.each file, &block
      PdbDic.new(file, &block)
    end
    def PdbDic.open(file, &block)
      PdbDic.new(file, &block)
    end
  end
end
