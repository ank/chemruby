require 'chem'

atp = Chem.load("data/atp.mol").cdk_setup

atp.cdk_generate_vicinity.each_with_index do |mol, n|
  mol2d = mol.cdk_generate_2D
  mol2d.save("temp/v#{n}.pdf")
end
