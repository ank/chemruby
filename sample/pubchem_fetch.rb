#!/usr/bin/env ruby

require 'open-uri'
 
cid = ARGV.shift
url = "http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?cid=#{cid}&disopt=DisplaySDF"
sdf = open(url).read
puts sdf
