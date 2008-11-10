
module Chem

  module Type
    module MdlRxnType

      def self.detect_file file
        File.extname(file) == '.rxn'
      end

      def self.parse file
        mol = MdlReaction.new
        mol.open_rxn file
      end

      def self.detect_type type
        type == :rxn
      end

    end
  end

  ChemTypeRegistry << Type::MdlRxnType

end
