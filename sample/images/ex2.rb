require 'chem'

mol = Chem.open_mol("mol/atp.mol")
mol.save("temp/ex2.png", :size => [300, 150])
