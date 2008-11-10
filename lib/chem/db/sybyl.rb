
module Chem

  module Molecule

    # Return sybyl formatted molecule
    def to_sybyl
    end

  end

  module Atom

    def to_sybyl
      "      1 C1         -3.262565   -0.588014   -0.082185 C.3       1 <1>        -0.020001 "
      "%7d" % [1]
    end

  end

  module Sybyl
    SybylAtomTypes = {
      "LP" => "lone pair",
      "Du" => "dummy atom",
      "Du.C" => "dummy carbon",
      "Hal" => "halogen",
      "Het" => "heteroatom = N, O, S, P",
      "Hev" => "heavy atom (non hydrogen)",

      "H" => "hydrogen",
      "H.spc" => "hydrogen in Single Point Charge (SPC) water model",
      "H.t3p" => "hydrogen in Transferable intermolecular Potential (TIP3P) water model",

      "C.2" => "carbon sp2",
      "C.1" => "carbon sp",
      "C.ar" => "carbon aromatic",
      "C.cat" => "carbocation (C+) used only in a guadinium group",
      "C.3" => "carbon sp3",

      "N.3" => "nitrogen sp3",
      "N.2" => "nitrogen sp2",
      "Any" => "any atom",
      "N.1" => "nitrogen sp",
      "N.ar" => "nitrogen aromatic",
      "N.am" => "nitrogen amide",
      "N.pl3" => "nitrogen trigonal planar",
      "N.4" => "nitrogen sp3 positively charged",
      "Li" => "lithium",
      "Na" => "sodium",

      "O.3" => "oxygen sp3",
      "O.2" => "oxygen sp2",
      "O.co2" => "oxygen in carboxylate and phosphate groups",
      "O.spc" => "oxygen in Single Point Charge (SPC) water model",
      "O.t3p" => "oxygen in Transferable Intermolecular Potential (TIP3P) water model",

      "Mg" => "magnesium",
      "Al" => "aluminum",
      "Si" => "silicon",
      "K" => "potassium",
      "Ca" => "calcium",

      "S.3" => "sulfur sp3",
      "S.2" => "sulfur sp2",
      "S.O" => "sulfoxide sulfur",
      "S.O2" => "sulfone sulfur",

      "Cr.th" => "chromium (tetrahedral)",
      "Cr.oh" => "chromium (octahedral)",

      "Mn" => "manganese",
      "Fe" => "iron",
      "P.3" => "phosphorous sp3",
      "Co.oh" => "cobalt (octahedral)",
      "F" => "fluorine",
      "Cu" => "copper",
      "Cl" => "chlorine",
      "Zn" => "zinc",
      "Br" => "bromine",
      "Se" => "selenium",
      "I" => "iodine",
      "Mo" => "molybdenum",
      "Sn" => "tin",
    }

    class SybylAtom

      include Atom

      def element ; @element ||= @line[53..60].split(".")[0].strip.intern ; end
      def x       ; @x       ||= @line[16..27].to_f                       ; end
      def y       ; @y       ||= @line[28..39].to_f                       ; end
      def z       ; @z       ||= @line[40..51].to_f                       ; end
      def initialize line ;      @line = line                             ; end

    end

    class SybylBond

      include Bond

      attr_reader :b, :e
      def initialize line
        # @line = line
        @b = line[6..10].to_i
        @e = line[11..15].to_i
        @v = line[16..17].to_i
      end

    end

    class SybylMolecule

      include Molecule
      include Enumerable

      def n_atoms ;  @n_atoms ||= @count_line[0..4].to_i ;                end
      def n_bonds ;  @n_bonds ||= @count_line[5..10].to_i ;               end
      #    def charge?
      def initialize filename
        @nodes = []
        @edges = []
        File.open(filename) do |input|
          input.read.split("\n@").each do |line|
            ary = line.split("\n")
            case ary[0]
            when /<TRIPOS>MOLECULE/
              parse_mol ary
            when /<TRIPOS>ATOM/
              ary[1..-1].each{|line| @nodes.push(SybylAtom.new(line))}
            when /<TRIPOS>BOND/
              ary[1..-1].each do |line|
                bond = SybylBond.new(line)
                @edges.push([bond, @nodes[bond.e - 1], @nodes[bond.b - 1]])
              end
            end
          end
        end
      end

      private
      def parse_mol ary
        @count_line = ary[2]
      end

    end

  end

end
