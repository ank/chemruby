

module Chem

  module Type
    module GSpanType

      def self.detect_file file
        File.extname(file) == '.fp'
      end

      def self.parse file
        # autoloaded
        # require 'chem/db/gspan.rb'
        Chem.parse_gspan(file)
      end

      def self.detect_type type
        type == :gspan
      end

      def self.save mol, filename, params = {}
        #      require 'chem/db/gspan.rb'
        Chem::GSpan.save(mol, filename, params)
      end
    end
  end

  ChemTypeRegistry << Type::GSpanType

end
