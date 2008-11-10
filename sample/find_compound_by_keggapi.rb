#!/usr/bin/env ruby

require 'rubygems'
require 'chem'
require 'soap/wsdlDriver'

SMILES("C1C(=O)NC(=O)S1").save("thiazolidinedione.mol")

wsdl = "http://soap.genome.jp/KEGG.wsdl"
serv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

molfile = File.open("thiazolidinedione.mol").read
results = serv.search_drugs_by_subcomp(molfile, 1, 30)

results.each do |mol|
  puts mol.target_id
  url = "-f m #{mol.target_id}"
  File.open(mol.target_id + ".mol", "w").print(serv.bget(url))
end
