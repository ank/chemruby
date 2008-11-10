
module Chem

  module Type

    module SybylType

      def self.detect_file file
        File.extname(file) == '.mol2'
      end

      def self.parse file
        require 'chem/db/sybyl'
        mol = Chem::Sybyl::SybylMolecule.new file
      end

      def self.detect_type type
        type == :sybyl
      end

      def self.save mol, filename
        mol.save_as_mdl(filename)
      end

    end
  end

  ChemTypeRegistry << Type::SybylType

end
