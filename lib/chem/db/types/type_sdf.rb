
module Chem

  module Type
    module SdfType

      def self.detect_file file
        File.extname(file) == '.sdf'
      end

      def self.parse file
        require 'chem/db/sdf.rb'
        MDL::SdfParser.parse file
      end

      def self.detect_type type
        type == :sdf
      end

    end
  end

  ChemTypeRegistry << Type::SdfType

end
