module Chem

  module Type
    
    module KCFGlycanType

      def self.detect_file file
        File.extname(file) == '.kcf' && /G\d+/.match(file)
      end

      def self.parse file
        require 'chem/db/kcf_glycan'
        mol = Chem::KEGG::KCFGlycan.new File.open(file)
      end

      def self.detect_type type
        type == :kcf_glycan
      end

    end

  end

  ChemTypeRegistry << Type::KCFGlycanType

end
