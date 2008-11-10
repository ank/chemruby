#
# 1. open file with Chem.open_mol
# 2. save the object with Molecule#save
# 3. No step 3 !

require 'chem'

mol = Chem.open_mol("mol/atp.mol")

mol.save("temp/ex1.png")

