#
#   tinker.rb - TINKER
#
# http://dasher.wustl.edu/tinker/
#
#

module Chem

  module TINKER

    class TinkerAtom

      include Atom

      attr_reader :x, :y, :z, :element, :connection
      def initialize ff, x, y, z, connection
        @x, @y, @z = x.to_f, y.to_f, z.to_f
        @element = ff[0..0]
        @connection = []
        connection.each do |n|
          @connection.push(n)
        end
      end
    end

    class TinkerBond

      include Bond
      
      attr_accessor :b, :e, :v, :q
      def initialize b, e
        @b, @e = b, e
      end
    end

    class TinkerMol
      attr_reader :atoms, :bonds

      def initialize
        @atoms = {}
        @bonds = []
      end

      def construct
        @atoms.each_value do |a|
          a.connection.each do |c|
            raise "unknown atom number %s" % @atoms.inspect if !@atoms.has_key?(c)
            bond = TinkerBond.new(a, @atoms[c])
            @bonds.push(bond)
          end
        end
      end

    end

    class TinkerReader

      attr_reader :mol

      def initialize input
        puts input.readline
        @mol = TinkerMol.new
        input.each_line do |line|
          number, ff, x, y, z, unknown, ary = line.split
          atom = TinkerAtom.new(ff, x, y, z, ary)
          @mol.atoms[number] = atom
        end

        @mol.construct
      end

    end

  end

end
