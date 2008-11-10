#
# model.rb - Abstract Model for Molecule, Atom and Bond
#
#
# $Id: model.rb 61 2005-10-12 09:17:39Z tanaka $
#

require 'graph'
require 'chem/utils/transform'

module Chem

  # Atom module is top level abstract module for atom in molecule.
  # It will be mixed-in to other concrete class.

  module Atom
    include Chem::Transform::ThreeDimension

    # true if visible (for visualization)
    attr_accessor :visible
    # [r, g, b]
    attr_accessor :color

    # atomic symbol (Symbol object)
    attr_accessor :element

    # x-axis position
    attr_accessor :x

    # y-axis position
    attr_accessor :y

    # z-axis position
    attr_accessor :z

    # charge
    attr_accessor :charge

    # atomic mass
    attr_accessor :mass

    # Returns Atomic Number.
    # If unknown return 100.
    def atomic_number
      Number2Element.index(element) ? Number2Element.index(element) : 100
    end

    # Returns atomic mass
    def mass
      return @mass if @mass
      return Chem::AtomicWeight[element] + @mass_difference if @mass_difference
      Chem::AtomicWeight[element]
    end

  end

  module Bond
    # Returns valency of bond
    # use bond_type
    attr_accessor :v

    # Returns Bond Stereo
    # this method may be overridden by concrete class
    # :not_stereo:: Not Stereo
    # :up:: Up
    # :down:: Down
    # :cis_trans:: Cis or Trans
    # :either:: Either
    def stereo ; :either ; end

    # Returns Bond Type
    # this method may be overridden by concrete class
    # :single:: Single bond
    # :double:: Double bond
    # :triple:: Triple bond
    # :aromatic:: Aromatic Bond
    # :single_or_double:: Single or Double bond
    # :single_or_aromatic:: Single or Aromatic bond
    # :double_or_aromatic:: Double or Aromatic bond
    # :any:: Any bond
    def bond_type ; :any ; end

    # Returns Topology of bond
    # this method may be overridden by concrete class
    # :either:: Either
    # :ring:: Ring
    # :chain:: Chain
    def topology ; :either ; end

    attr_accessor :color # set [r, g, b] for visualization

  end

  module Reaction

  end

  module Molecule

    include ::Graph

    attr_writer :source # source of molecule
    attr_writer :name   # name of molecule

    # Returns source of molecule.
    # default value is ""
    def source
      @source ? @source : ""
    end

    # Returns name of molecule.
    # default value is self.source
    def name
      @name ? @name : self.source
    end

  end

end

require 'chem/model/skeleton'

