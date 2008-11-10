# Chime XYZ parser

module Chem

  module XYZ

    class XyzAtom
      include Atom
      include Chem::Transform::ThreeDimension
    end

    class XyzMolecule

      include Molecule

      def initialize
        super
        @nodes = []
      end

      def open_xyz filename
        xyz = open(filename, "r")
        n_atoms = xyz.readline.to_i
        title = xyz.readline
        n_atoms.times do |n|
          array = xyz.readline.split
          a = XyzAtom.new
          a.element, a.x, a.y, a.z = array[0].intern, array[1].to_f, array[2].to_f, array[3].to_f
          @nodes.push(a)
        end
        self
      end

    end

  end

end

