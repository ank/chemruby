
module Chem

  module Type
    module XyzType

      def self.detect_file file
        File.extname(file) == '.xyz'
      end

      def self.parse file
        require 'chem/db/xyz.rb'
        mol = XYZ::XyzMolecule.new
        mol.open_xyz file
      end

      def self.detect_type type
        type == :xyz
      end

    end
  end

  ChemTypeRegistry << Type::XyzType

end
