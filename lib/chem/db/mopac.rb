#
# chem/mopac.rb - MOPAC7 format class
#

require 'chem/molecule'
require 'scanf'

module Chem
  module Mopac7
    class MopacReader
      def initialize entry
        ea = entry.split("\n")
        n_line = 0
        0.upto(ea.length) do |n|
          n_line = n if /SCF FIELD WAS ACHIEVED/ =~ ea[n]
        end
        n_atom = 0
        n_line.upto(ea.length) do |n|
          line = ea[n]
          if /FINAL HEAT OF FORMATION =\s+(\d+.\d+) KCAL/ =~ line
            @heat_of_formation = $1.to_f
          elsif /TOTAL ENERGY/ =~ line
            @total_energy = line.scanf("TOTAL ENERGY            =%f")
          elsif /ELECTRONIC ENERGY/ =~ line
            @electronic_energy = line.scanf("ELECTRONIC ENERGY       =%f")
          elsif /CORE-CORE REPULSION/ =~ line
            @core_core_repulstion = line.scanf("CORE-CORE REPULSION     =%f")
          elsif /GRADIENT NORM/ =~ line
            @gradient_norm = line.scanf("GRADIENT NORM           =%f")
          elsif /IONIZATION POTENTIAL/ =~ line
            @ionization_potential = line.scanf("IONIZATION POTENTIAL    =%f")
          elsif /NO. OF FILLED LEVELS/ =~ line
            @no_of_filled_levels = line.scanf("NO. OF FILLED LEVELS    =%d")
          elsif /MOLECULAR WEIGHT/ =~ line
            @molecular_weight = line.scanf("MOLECULAR WEIGHT        =%f")
          elsif /    ATOM   CHEMICAL  BOND LENGTH    BOND ANGLE     TWIST ANGLE/ =~ line
            Range.new(n+4, ea.length).each do |l|
              if '' == ea[l]
                n_atom = l - n - 4
                break
              end
              if /^      1/ =~ ea[l]
                ea[l].scanf("%d%s")
              elsif /^      2/ =~ ea[l]
                ea[l].scanf("%d%s%f*%d")
              elsif /^      3/ =~ ea[l]
                ea[l].scanf("%d%s%f*%f*%d%d")
              else
                ea[l].scanf("%d%s%f*%f*%f*%d%d%d")
              end
            end
          elsif /INTERATOMIC DISTANCES/ =~ line
            @distances = {}
            reduced = 0
            first = n + 3 + 1

            while n_atom - reduced> 0
              Range.new(first, first + n_atom - reduced - 1).each do |l|
                ary =  ea[l].scanf("%s%d"+"%f"* (l - first + 1))
                1.upto(l - first + 1) do |ll|
                  @distances[[ary[1], ll + reduced]] = ary[ll + 1]
                  @distances[[ll + reduced, ary[1]]] = ary[ll + 1]
                end
              end
              first = first + n_atom - reduced + 3
              reduced = reduced + 6
            end
#             1.upto(n_atom) do |nn|
#               print "%3d" % nn
#               1.upto(n_atom) do |mm|
#                 print " %3f" % @distances[[nn, mm]] if @distances[[nn, mm]]
#               end
#               puts
#             end
          elsif /MOLECULAR POINT GROUP/ =~ line
            @symmetry = line.scanf("MOLECULAR POINT GROUP   :%s")
          elsif /EIGENVECTORS/
            
          end
        end
      end
      def MopacReader.open_out file
        MopacReader.new(File.open(file, 'r').gets(nil))
      end
    end
  end
end

