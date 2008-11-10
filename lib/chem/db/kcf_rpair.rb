# This is stub
module Chem

  module KCF

    class RPairMolecule
      include Molecule

      def initialize input
        state = nil
        input.each do |line|
          case line[0..11]
          when "            "
            case state
            when :alignment
              idx, from, to = line.split
              from
            end
          when "ENTRY       "
          when "NAME        "
          when "COMPOUND    "
          when "TYPE        "
          when "ALIGN       "
            state = :alignment
            p line[11..-1].strip.to_i
          end
        end
      end

    end

  end

end
