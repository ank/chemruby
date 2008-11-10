require 'chem'

mol1 = Chem.load("data/troglitazone.mol")
mol2 = Chem.load("data/rosiglitazone.mol")

mol1.cdk_mcs(mol2).each_with_index do |mol, idx|
  mol1.hilight(mol.match(mol1)[0].values)
  mol1.save("temp/mcs-1-#{idx}.pdf")
  
  mol2.hilight(mol.match(mol2)[0].values)
  mol2.save("temp/mcs-2-#{idx}.pdf")

end
