require 'chem'

benzene = SMILES("C1=CC=CC=C1").cdk_setup

# Faulon, JCICS 1996, 36, 731

16.times do |n|
  benzene.\
  cdk_generate_randomly.\
  cdk_generate_2D.\
  cdk_save_as("temp/benzene#{n}.png")
end

