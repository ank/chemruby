$: << "/Users/tanaka/proj/chemruby/lib"
$: << "/Users/tanaka/proj/chemruby/ext"
$: << "/Users/tanaka/temp/bioruby/lib"

require 'bio'
require 'chem'

module Chem
  module PDB

    class PDBBond
      include Bond
    end

    class PDBMolecule
      include Chem::Molecule

      def initialize name
        @name = name
        @nodes = []
        @edges = []
      end

      # Set connection using het_dictionary
      def set_connection het_dic
        atom_hash = @nodes.inject({}){|ret, atom| ret[atom.name.strip] = atom ; ret}
        con = het_dic.find{|entry| entry.entry_id == @name}
        con.record["CONECT"].each do |b|
          if from = atom_hash[b.name.strip]
            b.other_atoms.each do |to_atom|
              if to = atom_hash[to_atom.strip]
                bond = PDBBond.new
                @edges.push([bond, from, to])
              end
            end
          end
        end
      end

    end

  end
end

module Bio

  class PDB

    def mols
      mols = {}
      @hash["HETATM"].each do |atom|
        mol = (mols[[atom.resName, atom.chainID]] ||= Chem::PDB::PDBMolecule.new(atom.resName))
        mol.nodes.push(atom)
      end
      mols
    end

    # reprensent one entry of het_dictionary.txt
    class ChemicalComponent
    end

    class Record::HETATM
      include Chem::Atom
      include Chem::Transform::ThreeDimension
      def pos ; @pos ||= Vector[@x, @y, @z] ; end
    end

  end

end

if __FILE__ == $0
  dir = "/Users/tanaka/data/"

  enzyme = Bio::FlatFile.auto(dir + "/pdb/1j4r.ent")

  mols = {}
  enzyme.each do |entry|
    entry.mols.each do |key, mol|
      p mol.nodes.length
      dic = Bio::FlatFile.auto(dir + "het_dictionary.txt")
      mol.set_connection(dic)
      mol.save("#{key.join('_')}.png")
    end
    exit
    entry.record("HETATM").each do |atom|
      (mols[atom.resName] ||= []).push atom
    end
  end

  # p mols.keys
end

#c001 = dic.find{|entry| entry.entry_id == "001"}

#p c001.hello#.record["CONECT"]

#p mols["001"]

__END__


pdb.each do |entry|
  p entry.entry_id
end
