$: << '../../lib/'
$: << '../../ext/'

require 'chem'

mol = Chem.open_mol("ATP.mol")
query = Chem.open_mol("adenine.mol")

m = mol.match_by_ullmann(query)
matched_nodes = m.inject([]){|ret, i| ret.push(mol.nodes[i])}

mol.edges.each do |bond, atom1, atom2|
  bond.color = [1, 0, 0] if matched_nodes.include?(atom1) and matched_nodes.include?(atom2)
end

mol.nodes.each{|node| node.visible = true unless node.element == :C}
mol.save("color.pdf")
