$: << "../../lib"
$: << "../../ext"

require 'chem'

mol = Chem.open_mol("mol/atp.mol")
query = Chem.open_mol("mol/adenine.mol")

m = mol.match(query)

mol.edges.each do |bond, atom1, atom2|
  bond.color = [1, 0, 0] if m.keys.include?(atom1) and m.keys.include?(atom2)
end

mol.nodes.each{|atom| atom.color = [1, 0, 0]}

mol.nodes.each{|node| node.visible = false unless node.element == :C}
mol.save("color.png")
