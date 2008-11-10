
module Chem

  module Type
    module GDType

      def self.detect_file file
        begin
          require 'GD'
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
        [:gd_png, :gd_gif, :gd_jpeg, :gd_tiff].include?(type)
      end

      def self.save mol, filename, params = {}
        require 'chem/db/gd.rb'
        GDWriter.save(mol, filename, params)
      end

    end
  end

  ChemTypeRegistry << Type::GDType

end
