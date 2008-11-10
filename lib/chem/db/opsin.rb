
module Chem

  def self.opsin_parse(iupac_name)
    OpsinMolecule.new(iupac_name)
  end

  class OpsinMolecule
    include Molecule

    def initialize(iupac_name)
      require 'rcdk'
      @iupac_name = iupac_name
      name2struct = Rjb::import('uk.ac.cam.ch.wwmm.opsin.NameToStructure').new
      @cml = name2struct.parseToCML(iupac_name).toXML.to_s
      @mol = Chem::CMLMolecule.new(@cml)
    end

    def nodes ; @mol.nodes ; end

    def edges ; @mol.edges ; end

  end
end
