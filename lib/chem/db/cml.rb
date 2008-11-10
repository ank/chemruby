require 'rexml/document'

module Chem

  class CMLAtom

    include Atom
    attr_reader :node_id

    def initialize(element, node_id)
      @element = element
      @node_id = node_id
    end

  end

  class CMLBond

    include Bond

    def initialize(v)
      @v = v
    end

  end

  class CMLMolecule
    include Molecule

    def initialize(str)
      @nodes = []
      @edges = []
      atom_refs = {}

      xml = REXML::Document.new(str)
      xml.elements.each("cml/molecule") do |molecule|
        molecule.elements.each("atomArray/atom") do |atom_element|
          atom = CMLAtom.new(atom_element.attributes["elementType"],
                             atom_element.attributes["id"])
          @nodes << atom
          atom_refs[atom.node_id] = atom
        end
        molecule.elements.each("bondArray/bond") do |bond_element|
          from, to = (bond_element.attributes["atomRefs2"]).split(" ")
          valence  = bond_element.attributes["order"].to_i
          @edges << [CMLBond.new(valence), atom_refs[from], atom_refs[to]]
        end
      end
    end

  end
end
