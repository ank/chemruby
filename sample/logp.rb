require 'rubygems'
require 'chem'
#test/data/atp.mol
p Chem.load("data/atp.mol").cdk_xlogp
