#!/usr/bin/env ruby

require 'rubygems'
require 'chem'
                                                                              
troglitazone = Chem.load("troglitazone.mol")
rosiglitazone = Chem.load("rosiglitazone.mol")
 
mcs = troglitazone.cdk_mcs(rosiglitazone)

map = mcs[0].match(troglitazone)[0]

map.each_value do |atom|
  atom.color = [1, 0, 0]
end

troglitazone.edges.each do |bond, from, to|
  if map.values.include?(from) and map.values.include?(to)
    bond.color = [1, 0, 0]
  end
end

troglitazone.remove_hydrogens!
troglitazone.save("mcs.pdf")

  

