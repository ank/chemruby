
module Chem

  module Type

    module RDFType
      def self.detect_file file
        File.extname(file) == '.rdf'
      end

      def self.parse file
        require 'chem/db/mdl.rb'
      end

      def self.detect_type type
        type == :rdf
      end
    end

  end

end
