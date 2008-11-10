require 'chem'

mol = Chem.open_mol("mol/atp.mol")
mol.nodes.each{|node| node.visible = true unless node.element == :C}
mol.save("temp/ex3.png")
