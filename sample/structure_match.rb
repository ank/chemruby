#!/usr/bin/env ruby

require 'rubygems'
require 'chem'

mol = Chem.load("troglitazone.mol")
query = SMILES("C1C(=O)NC(=O)S1")
p query.match(mol)
