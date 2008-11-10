# $Id: ctab_test.rb 61 2005-10-12 09:17:39Z tanaka $

module Chem
  module CtabTest

    def test_respond_to_element
      @entries.each do |mol|
        mol.all? do |atom|
          assert_respond_to(atom, :element)
        end
      end
    end

    def test_nodes
      @entries.each do |mol|
        mol.nodes.each do |atom|
          assert_instance_of(Symbol, atom.element)
        end
      end
    end

    def test_edges
      @entries.each do |mol|
        mol.edges.each do |bond, atom_a, atom_b|
          assert_instance_of(Fixnum, bond.v)
        end
      end
    end

  end
end
