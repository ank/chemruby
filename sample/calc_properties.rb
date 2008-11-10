#!/usr/bin/env ruby

require 'rubygems'
require 'chem'
                                                                                         
Dir.glob("*.mol").each do |file|
  mol = Chem.load(file)
  p [mol.cdk_xlogp, mol.cdk_wiener_numbers]
end 
