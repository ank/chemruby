
module Chem

  module Type
    module PNGType

      def self.detect_file file
        begin
          require 'RMagick'
        rescue LoadError
          return false
        end
        ['.png', '.gif', '.jpg', '.jpeg', '.tiff'].include?(File.extname(file))
      end

      # ChemRuby will never parse PNG ;)
      def self.parse file
        raise NotImplementedError
      end

      def self.detect_type type
        type == :png
      end

      def self.save mol, filename, params = {}
        require 'chem/db/rmagick.rb'
        RMagickWriter.save(mol, filename, params)
      end

    end
  end

  ChemTypeRegistry << Type::PNGType

end
