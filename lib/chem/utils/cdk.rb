# Copyright (C) 2006 Richard L. Apodaca
#                    Nobuya     Tanaka

module Chem

  module CDK

    def self.parse_mdl(str)
      require 'rcdk'
      reader    = Rjb::import('java.io.StringReader').new(str)
      mdlreader = Rjb::import('org.openscience.cdk.io.MDLReader').new(reader)
      molcls    = Rjb::import('org.openscience.cdk.Molecule')

      CDKMolecule.new(mdlreader.read(molcls.new))
    end

    class CDKAtom

      include ::Chem::Transform::TwoDimension# fix me!
      include Atom
      attr_reader :cdk_atom

      def initialize(cdk_atom)
        @cdk_atom = cdk_atom
      end

      def element ; @cdk_atom.getSymbol.intern   ; end
      def x ;       @cdk_atom.getX2d             ; end
      def y ;       @cdk_atom.getY2d             ; end

    end

    class CDKBond

      include Bond

      def initialize(cdk_bond)
        @cdk_bond = cdk_bond
      end

      def v ; @cdk_bond.getOrder ; end

    end

    class CDKMolecule
      include Molecule
      include ::Graph

      attr_reader :cdk_mol, :nodes, :edges
      def initialize(cdk_mol)
        @cdk_mol = cdk_mol
        setup_nodes_and_edges
      end

      def setup_nodes_and_edges
        @nodes    = []
        @edges    = []
        @cdk2atom = {}

        enum = @cdk_mol.atoms
        while(enum.hasMoreElements)
          cdkatom = enum.nextElement
          atom    = CDKAtom.new(cdkatom)
          @cdk2atom[cdkatom.hashCode] = atom
          @nodes << atom
        end

        tmp = {}
        @nodes.each do |from|
          tmp[from.cdk_atom.hashCode] ||= {}
          @cdk_mol.getConnectedAtoms(from.cdk_atom).each do |to|

            if tmp[from.cdk_atom.hashCode][to.hashCode].nil?
              bond = @cdk_mol.getBond(from.cdk_atom, to)

              tmp[from.cdk_atom.hashCode][to.hashCode] = bond
              tmp[to.hashCode] ||= {}
              tmp[to.hashCode][from.cdk_atom.hashCode] = bond

              @edges << [CDKBond.new(bond), from, @cdk2atom[to.hashCode]]

            end
          end
        end

      end

    end

    def self.parse_smiles(smiles)
      require 'rcdk'
      smiles_parser = Rjb::import('org.openscience.cdk.smiles.SmilesParser').new
      CDKMolecule.new(smiles_parser.parseSmiles(smiles))
    end

#     def self.load(path)
#       factory = Rjb::import('org.openscience.cdk.templates.MoleculeFactory').new
#       factory.loadMolecule(path)
#     end

  end # CDK module

  module Atom
    attr_accessor :cdk_atom
  end

  module Molecule

    attr_reader :cdk_mol, :cdk2atom

    def cdk_generate_2D
      cdk_setup
      @@gen_cls ||= Rjb::import('org.openscience.cdk.layout.StructureDiagramGenerator')
      generator = @@gen_cls.new#(self.cdk_mol)
      generator.setMolecule(self.cdk_mol)
      generator.generateCoordinates
      Chem::CDK::CDKMolecule.new(generator.getMolecule)
    end
    alias cdk_calc_2d cdk_generate_2D

    def cdk_find_all_rings
      cdk_setup

      @@ring_finder ||= Rjb::import('org.openscience.cdk.ringsearch.AllRingsFinder').new
      r_p ||= Rjb::import('org.openscience.cdk.ringsearch.RingPartitioner')
      ringset = @@ring_finder.findAllRings(self.cdk_mol)
      enum = r_p.partitionRings(ringset).elements
      rings = []
      while(enum.hasMoreElements)
        ring = []
        ac = r_p.convertToAtomContainer(enum.nextElement)
        atom_enum = ac.atoms
        puts "--"
        while(atom_enum.hasMoreElements)
          ring << cdk2atom[atom_enum.nextElement.hashCode]
        end
        rings << ring
      end
      rings
    end

    def cdk_sssr
      cdk_setup

      @@sssr_finder ||= Rjb::import('org.openscience.cdk.ringsearch.SSSRFinder')
      r_p ||= Rjb::import('org.openscience.cdk.ringsearch.RingPartitioner')
      sssr = @@sssr_finder.new(self.cdk_mol)
      enum = r_p.partitionRings(sssr.findSSSR).elements

      rings = []
      while(enum.hasMoreElements)
        ring = []
        ac = r_p.convertToAtomContainer(enum.nextElement)
        atom_enum = ac.atoms
        puts 
        while(atom_enum.hasMoreElements)
          ring << cdk2atom[atom_enum.nextElement.hashCode]
        end
        rings << ring
      end
      rings
    end

    def cdk_generate_randomly
      cdk_setup
      gen = Rjb::import('org.openscience.cdk.structgen.RandomGenerator').new(self.cdk_mol)
      CDK::CDKMolecule.new(gen.proposeStructure)
    end

    def cdk_generate_vicinity
      cdk_setup
      gen = Rjb::import('org.openscience.cdk.structgen.VicinitySampler').new(self.cdk_mol)
      ary = gen.sample(self.cdk_mol)
      enum = ary.elements
      ret = []
      while enum.hasMoreElements
        ret << CDK::CDKMolecule.new(enum.nextElement)
      end
      ret
    end

    #HueckelAromaticityDetector
    def cdk_hueckel
      cdk_setup
      huckel = Rjb::import('org.openscience.cdk.aromaticity.HueckelAromaticityDetector')
      huckel.detectAromaticity(self.cdk_mol)
    end

    # Fix me !
    #  Fail: unknown method name `assignGasteigerMarsiliFactors
    def cdk_gasteiger_marsili_partial_charges(params = {})
      cdk_setup
      gm = Rjb::import('org.openscience.cdk.charges.GasteigerMarsiliPartialCharges').new
      gm.setChiCatHydrogen = params[:deoc_hydrogen] if params[:deoc_hydrogen]
      p gm.getStepSize
      p gm.assignGasteigerMarsiliFactors(self.cdk_mol)
#      gm.assignGasteigerMarsiliFactors(self.cdk_mol)
#      gm.assignGasteigerMarsiliPartialCharges(self.cdk_mol, false)
#      gm.assignGasteigerMarsiliPartialCharges(self.cdk_mol, true)
    end

    # Return HOSE code
    # Anal. Chim. Acta. (1978) 103:355-365
    def cdk_hose_code(atom, depth = 3)
      hose_gen = Rjb::import('org.openscience.cdk.tools.HOSECodeGenerator').new
      hose_gen.getHOSECode(mol, mol.getAtomAt(9), 3)
    end

    def cdk_BCUT
    end

    def cdk_fingerprint
      'org.openscience.cdk.fingerprint.Fingerprinter'
    end

    def cdk_setup
      return unless self.cdk_mol.nil?
      require 'rcdk'
      atom_class = Rjb::import('org.openscience.cdk.Atom')
      bond_class = Rjb::import('org.openscience.cdk.Bond')
      ac         = Rjb::import('org.openscience.cdk.AtomContainer').new
      point3d    = Rjb::import('javax.vecmath.Point3d')
      point2d    = Rjb::import('javax.vecmath.Point2d')
      i = 0
      @cdk2atom = {}
      atoms = nodes.collect{ |node|
        i += 1
        atom = atom_class.new(node.element.to_s)

#        atom.setPoint3d(point3d.new(node.x.to_f, node.y.to_f, node.z.to_f))
#        atom.setPoint2d(point2d.new(node.x.to_f, node.y.to_f, node.z.to_f))

        atom.setSymbol(node.element.to_s)
        node.cdk_atom = atom
        @cdk2atom[atom.hashCode] = node
        atom
      }
      ac.setAtoms(atoms)
      edges.each do |edge, node1, node2|
        atom1 = ac.getAtomAt(nodes.index(node1))
        atom2 = ac.getAtomAt(nodes.index(node2))
        bond = bond_class.new(atom1, atom2, edge.v.to_f)
        ac.addBond(bond)
        @cdk_mol = Rjb::import('org.openscience.cdk.Molecule').new(ac)
      end
      self
    end

    def cdk_xlogp
      self.cdk_setup
      add_hydrogen = Rjb::import('org.openscience.cdk.tools.HydrogenAdder').new
      add_hydrogen.addExplicitHydrogensToSatisfyValency(self.cdk_mol)
      xlogp = Rjb::import('org.openscience.cdk.qsar.descriptors.molecular.XLogPDescriptor').new
      xlogp.setParameters([true, true])
      xlogp.calculate(self.cdk_mol).getValue().doubleValue
    end

    def cdk_mcs(other)
      self.cdk_setup
      other.cdk_setup

      mcsClass = Rjb::import('org.openscience.cdk.isomorphism.UniversalIsomorphismTester')
      iso = mcsClass.getOverlaps(self.cdk_mol, other.cdk_mol)
      maps = []
      itr = iso.iterator
      while(itr.hasNext)
        maps << CDK::CDKMolecule.new(itr.next)
      end
      maps
    end

    DESCRIPTORNAME = 'org.openscience.cdk.qsar.descriptors.molecular.'
    def cdk_calc_descriptor(name, args = [])
      self.cdk_setup
      calc = Rjb::import(DESCRIPTORNAME + name).new
      calc.setParameters(args)
      res = calc.calculate(self.cdk_mol).getValue
      case res._classname
      when "org.openscience.cdk.qsar.result.IntegerResult"
        res.intValue
      when "org.openscience.cdk.qsar.result.DoubleResult"
        res.doubleValue
      when "org.openscience.cdk.qsar.result.IntegerArrayResult"
        (0..(res.size - 1)).to_a.collect{|n| res.get(n)}
      when "org.openscience.cdk.qsar.result.DoubleArrayResult"
        (0..(res.size - 1)).to_a.collect{|n| res.get(n)}
      end
    end

    # Wiener path number
    # Wiener polarity number
    def cdk_wiener_numbers
      cdk_calc_descriptor('WienerNumbersDescriptor')
    end

    # CPSA
    def cdk_CPSA
      cdk_calc_descriptor('CPSADescriptor')
    end

    #BCUT Descriptors ....
    # Fix me!
    def cdk_BCUT(params)
      cdk_calc_descriptor('BCUTDescriptor', params)
    end

    # Lipinki's Rule of file
    def cdk_rule_of_file(params = true)
      cdk_calc_descriptor('RuleOfFiveDescriptor', [params])
    end

    #

    # args : terminal atoms must be included in the count
    def cdk_RotatableBondsCount(rot = [true])
      cdk_calc_descriptor('RotatableBondsCountDescriptor', rot)
    end

    # dump CDK properties...
    # useless...
    def cdk_properties
      self.cdk_setup
      hash = self.cdk_mol.getProperties
      keys = hash.keys
      while(keys.hasMoreElements)
        k = keys.nextElement
        p k.toString
        if /org.openscience.cdk.qsar.DescriptorSpecification/.match(k.toString)
          p [
            k.getImplementationIdentifier,
            k.getImplementationTitle,
            k.getImplementationVendor,
            k.getSpecificationReference
          ]
        end
        p hash.get(k).toString
      end
    end

    # fixme
    # this method does not work very well
    def cdk_calc_descriptors
      self.cdk_setup
      engineClass = Rjb::import('org.openscience.cdk.qsar.DescriptorEngine')
      # 1: atom
      # 2: bond?
      # 3: molecule?
      engine = engineClass.new(2)
      engine.process(self.cdk_mol)
    end

    def cdk_save_as(path, params = {})
      self.cdk_setup

      params[:type]   ||= :png
      params[:width]  ||= 100
      params[:height] ||= 100

      image_kit = Rjb::import('net.sf.structure.cdk.util.ImageKit')
      case params[:type]
      when :png
        image_kit.writePNG(self.cdk_mol, params[:width], params[:height], path)
      when :svg
        image_kit.writeSVG(self.cdk_mol, params[:width], params[:height], path)
      when :jpg
        image_kit.writeJPG(self.cdk_mol, params[:width], params[:height], path)
      end
    end

  end# Molecule module

end

if __FILE__ == $0

  mol  = Chem::CDK::parse_smiles("C1CCC=N1")

elsif false

  mol1  = Chem::CDK::parse_smiles("C1CCC=N1")
  mol2 = mol1.cdk_generate_2D

  mol1.cdk_save_as_image("sample1.svg", :type => :svg)
  mol2.cdk_save_as_image("sample2.svg", :type => :svg)

  DIR = "/Users/tanaka/data/kegg/ligand/mol/C%05d.mol"
  mols = [8434, 8435].collect{|filename|
    Chem::CDK::parse_mdl(File.open(DIR % filename).read)
  }

  # mcs = mols[0].cdk_mcs(mols[1]).each do |map|
  #   p map.nodes.length
  # end

  p mols[0].cdk_wiener_numbers
  p mols[0].cdk_generate_2d_coordinates._classname

#  p mols[0].cdk_calc_descriptors
#  p mols[0].cdk_properties

end


