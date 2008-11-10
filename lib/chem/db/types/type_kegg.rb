
module Chem

  module Type

    module KeggReactionType

      def self.detect_file filename
        if File.basename(filename) == "reaction"
          File.open(filename) do |file|
            return true if /ENTRY       /.match(file.readline)
          end
        end
      end

      def self.parse file
        require 'chem/db/kegg'
        Chem::KEGG::KeggReactionParser.new file
      end

      def self.detect_type type
        type == :kegg_reaction
      end

    end
  end

  ChemTypeRegistry << Type::KeggReactionType

  module Type

    module KeggReactionMapType

      def self.detect_file filename
        return true if File.basename(filename) == 'reaction_mapformula.lst'
      end

      def self.parse file
        require 'chem/db/kegg'
        Chem::KEGG::KeggReactionMapParser.new file
      end

      def self.detect_type type
        type == :kegg_rxn_map
      end

    end
  end

  ChemTypeRegistry << Type::KeggReactionMapType

  module Type
    module KeggReactionLstType

      def self.detect_file filename
        return true if File.basename(filename) == 'reaction.lst'
      end

      def self.parse file
        require 'chem/db/kegg.rb'
        Chem::KEGG::KeggReactionLstParser.new file
      end

      def self.detect_type type
        type == :kegg_rxn_lst
      end

    end
  end

  ChemTypeRegistry << Type::KeggReactionLstType

  module Type
    module KeggGlycanType

      def self.detect_file filename
        return true if File.basename(filename) == "glycan"
      end

      def self.parse file
        require 'chem/db/kegg.rb'
        Chem::KEGG::KeggGlycanParser.new file
      end

      def self.detect_type type
        type == :kegg_glycan
      end

    end
  end

  ChemTypeRegistry << Type::KeggGlycanType

end
