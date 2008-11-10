
module Chem

  module Type
    module CdxType

      def self.detect_file file
        File.extname(file) == '.cdx'
      end

      def self.parse file
        #      require 'chem/db/cdx.rb'
        mol = CDX::CDX.new
        mol.open file
      end

      def self.detect_type type
        type == :cdx
      end
    end
  end

  ChemTypeRegistry << Type::CdxType
end
