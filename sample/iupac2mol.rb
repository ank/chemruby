#!/usr/bin/env ruby

require 'rubygems'
require 'chem'

iupac_name = "5-[[4-[2-(methyl-pyridin-2-yl-amino)ethoxy]phenyl]methyl]-1,3-thiazolidine-2,4-dione"
opsin_mol = Chem.opsin_parse(iupac_name)
opsin_mol.save("rosiglitazone.mol")
