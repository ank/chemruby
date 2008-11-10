#!/usr/bin/env ruby

require 'rubygems'
require 'chem'

molfile = ARGV.shift
mols = Chem.load(molfile, :sdf)
sk = mols.to_a[0].pubchem_subskeys
puts "%0880b" % sk
p sk.to_bit_positions
p sk.to_bit_positions.length
