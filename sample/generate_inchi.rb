#!/usr/bin/env ruby

require 'rubygems'
require 'chem'

mol = Chem.load("troglitazone.mol")
puts mol.to_inchi
