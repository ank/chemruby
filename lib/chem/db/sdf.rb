

module Chem

  module MDL

    class MdlMolecule
      attr_accessor :sdf_data
    end    

    class SdfParser
      include Enumerable

      def initialize file
        require 'chem/db/mdl'
        @input = open(file)
      end

      def each
        @input.rewind

        # for \r\n and \n
        first_entry = true
        from = 0
        @input.each("$$$$") do |entry|
          from = entry.index("\n") + 1 unless first_entry
          first_entry = false
          next if entry[from..-1].length < 3
          molio = StringIO.new(entry[from..-1])
          mol = MdlMolecule.parse_io(molio)
          mol.sdf_data = {}
          data_header = nil

          molio.each do |line|
            if line[0..0] == ">"
              if /<([^>]+)>/.match(line)
                data_header = $1
              elsif /(DT\d+)/.match(line)
                data_header = $1
              end
              mol.sdf_data[data_header] = []
            elsif /^$/.match(line)
              if mol.sdf_data[data_header].respond_to?(:join)
                mol.sdf_data[data_header] = mol.sdf_data[data_header].join("\n")
              end
              # end of data
            else
              mol.sdf_data[data_header] << line.chop
            end
          end
          yield mol
        end

      end

      def self.parse file
        SdfParser.new(file)
      end

    end
    
  end
end
