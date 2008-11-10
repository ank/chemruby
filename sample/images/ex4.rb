require 'chem'

mol = Chem.open_mol("mol/atp.mol")
mol.nodes.each do |node|

  node.visible = true unless node.element == :C

  case node.element
  when :O
    node.color = [1, 0, 0]
  when :N
    node.color = [0, 0, 1]
  end

end

mol.save("temp/ex4.png")
