# $Id: coord_test.rb 61 2005-10-12 09:17:39Z tanaka $

module Chem
  module CoordTest
    # Tests to ensure classes has correct information for coordinate

    def test_coordinate
      @entries.each do |mol|
        mol.nodes.each do |atom|
          assert_kind_of(Float, atom.x)
          assert_kind_of(Float, atom.y)
        end
      end
    end

  end
end
