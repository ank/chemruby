#!/usr/local/bin/ruby

require 'chem/molecule'
require 'scanf'

module Chem

  # parser for msi file
  # MSI : Molecular Simulation Inc. 
  module MSI

    module MSIObject

      attr_accessor :parent, :child, :prop

      def initialize n = 0
        @prop = {}
        @n = n
      end

      def child= child
        @child = child
        child.parent = self
      end

    end

    class MSIFile
      include MSIObject
    end

    class Model < Molecule
      include MSIObject
    end

    class MSIAtom < Atom

      include MSIObject

      def b
        @prop['Atom1']
      end

      def e
        @prop['Atom2']
      end

    end

    class MSIBond < Bond
      include MSIObject
    end

    class MSIReader

      def MSIReader.open input
        MSIReader.new(input)
      end

      def model
        @top
      end

      def initialize input
        @objects = {}
        @input = input
      end

      def read
        current = MSIFile.new
        @top = current
        @input.each_line do |l|
          if /\((\d+) (\S+)/ =~ l
            case $2
            when 'Model'
              current.child = Model.new($1)
              current = current.child
            when 'Atom'
              current.child = MSIAtom.new($1)
              current = current.child
            when 'Bond'
              current.child = MSIBond.new($1)
              current = current.child
            end
            @objects[$1.to_i] = current
          elsif /\(A (\S) (\S+) (.+)\)/ =~ (l)
            case $1
            when 'C'
              current.prop[$2] = $3
            when 'I'
              current.prop[$2] = $3.to_i
            when 'O'
              current.prop[$2] = @objects[$3.to_i]
            when 'D'
              current.prop[$2] = $3.scanf("(%f %f %f")
            end
          elsif /\s+\)/ =~ l
            current = current.parent
          end
        end
      end

    end

  end
end

