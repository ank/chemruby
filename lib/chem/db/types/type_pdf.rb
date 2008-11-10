
module Chem

  module Type

    module PDFType

      def self.detect_file file
        File.extname(file) == '.pdf'
      end

      # ChemRuby will never parse PDF ;)
      def self.parse file
        raise NotImplementedError
      end

      def self.detect_type type
        type == :pdf
      end

      def self.save mol, filename, params = {}
        require 'chem/db/pdf.rb'
        open(filename, "w") do |out|
          mol.save_as_pdf(out, params)
        end
      end

    end
  end

  ChemTypeRegistry << Type::PDFType

end
