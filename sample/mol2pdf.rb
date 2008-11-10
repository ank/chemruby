#!/usr/bin/env ruby

require 'rubygems'
require 'chem'
 
mol=Chem.load("rosiglitazone.mol")
mol2 = mol.cdk_calc_2d
mol2.save("rosiglitazone.pdf")
