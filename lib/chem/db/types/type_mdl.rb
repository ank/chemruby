
module Chem

  module Type
    module MdlMolType

      def self.detect_file file
        File.extname(file) == '.mol'
      end

      def self.parse file
        # autloaded
        require 'chem/db/mdl.rb'
        mol = Chem::MDL::MdlMolecule.new
        mol.open file
      end

      def self.detect_type type
        type == :mdl
      end

      def self.save mol, filename, params = {}
        require 'chem/db/mdl.rb'
        mol.save_as_mdl(filename)
      end
    end
  end

  ChemTypeRegistry << Type::MdlMolType

end
