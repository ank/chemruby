require 'chem'

mol = Chem.open_mol("mol/atp.mol")

mol.nodes.each do |node|
  node.visible = true unless node.element == :C
end

mol.save("temp/ex5.png", :size => [350, 350])

