# Copyright (C) 2006 Richard L. Apodaca
#                    Nobuya     Tanaka

require 'chem'

module Chem

  module Atom
    attr_accessor :ob_atom
  end

  module Molecule

    attr_reader :ob_mol
    def ob_save_as(path, filetype)
      use_open_babel if @ob_mol.nil?
      conv = ::OpenBabel::OBConversion.new
      conv.set_out_format(filetype.to_s)
      conv.write_file(@ob_mol, path)
    end

    def ob_export_as(filetype)
      use_open_babel if @ob_mol.nil?
      conv = ::OpenBabel::OBConversion.new
      conv.set_out_format(filetype.to_s)
      conv.write_string(@ob_mol)
    end

    def to_inchi
      use_open_babel
      ob_export_as("inchi").chop
    end

    # set OpenBabel OBMol object to instance variable @ob_mol
    def use_open_babel
      begin
        require 'openbabel'
      rescue Exception
        require 'OpenBabel'
      end
      @ob_mol = ::OpenBabel::OBMol.new
      nodes.each do |node|
        atom = @ob_mol.new_atom
        atom.set_atomic_num(Element2Number[node.element])
        atom.set_vector(node.x.to_f, node.y.to_f, node.z.to_f)
        node.ob_atom = atom
      end
      edges.each do |bond, atom1, atom2|
        @ob_mol.add_bond(
                         atom1.ob_atom.get_idx,
                         atom2.ob_atom.get_idx,
                         bond.v.to_i
                         )
      end
    end

  end

  module OpenBabel

    def self.parse_smiles(smiles)

      require 'openbabel'

      converter = ::OpenBabel::OBConversion.new
      converter.set_in_format("smi")
      mol = ::OpenBabel::OBMol.new
      converter.read_string(mol, smiles)
      OBMolecule.new(mol)
    end

    def self.load_sdf(path)
      require 'openbabel'

      conv = ::OpenBabel::OBConversion.new
      conv.set_in_format("sdf")
      mol  = ::OpenBabel::OBMol.new
      cond = conv.read_file(mol, path)
      mols = [OBMolecule.new(mol)]
      while cond
        mol  = ::OpenBabel::OBMol.new
        cond = conv.read(mol)
        mols << OBMolecule.new(mol) if cond
      end
      mols
    end

    class OBSmarts

      def initialize(smarts)
        require 'openbabel'
        @pat = ::OpenBabel::OBSmartsPattern.new
        @pat.init(smarts)
        @pat
      end

      def match(mol)
        mol.use_open_babel if mol.ob_mol.nil?
        @pat.match(mol.ob_mol)
      end

      def get_umap_list
        @pat.get_umap_list.collect{|ary| ary.collect{|i| i.to_i}}
      end

    end

    def self.parse_smarts(smarts)
      OBSmarts.new(smarts)
    end

    # load_as(path, filetype)
    # path     : path to input file
    # filetype : "alc", "bgf"
    # see http://openbabel.sourceforge.net/wiki/Babel
    def self.load_as(path, filetype)
      conv = ::OpenBabel::OBConversion.new
      conv.set_in_format(filetype.to_s)
      mol  = ::OpenBabel::OBMol.new
      conv.read_file(mol, path)
      OBMolecule.new(mol)
    end

    module OBAtom
      include Atom
    end

    class OBMolecule
      include Molecule

      attr_reader :ob_mol
      attr_reader :nodes
      def initialize(ob_mol)
        @ob_mol = ob_mol
        @nodes = []
        1.upto(@ob_mol.num_atoms) do |n|
          atom = @ob_mol.get_atom(n)
          @nodes << atom.extend(OBAtom)
        end
      end

    end
  end # OpenBabel module
  
end

if __FILE__ == $0
  mol = SMILES("CCC")
  mol.use_open_babel
  p mol.num_atoms
  p mol.num_bonds
  p mol.get_mol_wt
  p mol.get_exact_mass
  # p mol.add_hydrogens # BUS Error !?
elsif false
  ob = Chem::OpenBabel.parse_smiles('CC(C)CCCC(C)C1CCC2C1(CCC3C2CC=C4C3(CCC(C4)O)C)C')
  p ob.get_mol_wt
  p ob.num_atoms
  p ob.num_bonds
  # read
  # is_last

  atom = ob.new_atom

# creating new molecule

  mol = OBMol.new
  atom1 = mol.add_atom
  atom2 = mol.add_atom

  # Atom

  atom1 = mol.get_first_atom
  atom1 = mol.get_atom(1)

  # Atom setter and getter

  atom1.set_atomic_num(6) # Carbon

  atom1.get_atomic_mass   # Carbon : 12.0107

  atom1.set_aromatic      # aromatic
  atom1.unset_aromatic    # not aromatic
  atom1.is_aromatic       # return true or false

  atom1.is_amide_nitrogen # return true or false
  

  # atom count starts from 1 (not 0)
  # mol.add_bond(0, 1, 1) fails!
  mol.add_bond(1, 2, 1)# from, to, bond_order
  # bond count starts from 0 (not 1)

  bond = mol.get_bond(0)
  bond.is_double
  bond.is_single
  bond.is_amide
  bond.get_bond_order # bond.get_bo

  # bond length

  bond.get_length
  bond.set_length# arguments ?
end
