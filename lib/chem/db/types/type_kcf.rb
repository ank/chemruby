
module Chem

  module Type
    module KCFType

      # Returns true if extension of file is .kcf and
      # file name starts C-number
      def self.detect_file file
        File.extname(file) == '.kcf' && /C\d+/.match(file)
      end

      # Parse file as KCF
      def self.parse file
        require 'chem/db/kcf'
        Chem::KEGG::KCF.new(File.open(file))
      end

      def self.detect_type type
        type == :kcf
      end

    end
  end

  ChemTypeRegistry << Type::KCFType

  module KCFRPairType

    def self.detect_file file
      File.extname(file) == '.kcf' && /A\d+/.match(file)
    end

    def self.parse file
      require 'chem/db/kcf_rpair'
      Chem::KCF::RPairMolecule.new(File.open(file))
    end

    def self.detect_type type
      type == :kcf_rpair
    end

  end

  ChemTypeRegistry << KCFRPairType

end
