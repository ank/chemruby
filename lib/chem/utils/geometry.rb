
module Chem

  module Molecule

    # Return size of molecule with Array [x, y, z]
    def box_size
      size_x = nodes().max{|a1, a2| a1.x <=> a2.x}.x - nodes().min{|a1, a2| a1.x <=> a2.x}.x
      size_y = nodes().max{|a1, a2| a1.y <=> a2.y}.y - nodes().min{|a1, a2| a1.y <=> a2.y}.y
      size_z = nodes().max{|a1, a2| a1.z <=> a2.z}.z - nodes().min{|a1, a2| a1.z <=> a2.z}.z
      [size_x, size_y, size_z]
    end

    # Automatically assigns 2-dimensional geometry
    # This method may implicitly called from ChemRuby
    # if nil is assigned to Atom#x
    def assign_2d_geometry
      geometrical_type(nodes[0])
    end

    private
    # 
    def geometrical_type atom
#       adj = adjacent_to(atom)
#       case adj.length
#       when 1
#       when 2
#       when 3
#       when 4
#       end
    end

  end

end
