#!/usr/bin/env ruby

require 'rubygems'
require 'chem'
                                                                                
target = Chem.load("troglitazone.mol")
query  = SMILES("C1C(=O)NC(=O)S1")
 
hash = query.match(target)[0]
p hash
hash.each_value do |atom|
  atom.color = [1, 0, 0]
end
 
target.edges.each do |bond, from, to|
  if hash.values.include?(from) and hash.values.include?(to)
    bond.color = [1, 0, 0]
  end
end

target.remove_hydrogens!
target.save("troglitazone.pdf")
