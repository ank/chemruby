#!/usr/bin/env ruby

require 'chem'

term = ARGV.shift

query = {
   :db     => :pccompound,
   :term   => term
}
 
p Chem::NCBI::ESearch.search(query)
