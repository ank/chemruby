#!/usr/local/bin/ruby
# obsolete class
require 'rexml/document'

include REXML


module Chem
  module SMBL

    class Specie
      attr_reader :name
      def initialize name, compartment, boundaryCondition, initialAmount
        @name = name
        @compartment = compartment
        @boundaryCondition = "false" == boundaryCondition
        @initialAmount = initialAmount.to_f
      end
    end

    class SMBLReaction

      attr_reader :reactants, :products, :name
      def initialize name, reversible
        @name = name
        @reversible = reversible
        @reactants = []
        @products = []
      end
    end

    class Model
      attr_reader :species, :reactions
      def initialize
        @species = {}
        @reactions = []
      end
    end

    doc = Document.new(file)

    model = Model.new

    doc.elements.each("*/model/listOfSpecies/specie") do |s|
      model.species[s.attribute("name").to_s] = Specie.new(s.attribute("name").to_s,
                                                           s.attribute("compartment").to_s,
                                                           s.attribute("boundaryCondition").to_s,
                                                           s.attribute("initialAmount").to_s)
    end

    doc.elements.each("*/model/listOfReactions/reaction") do |r|
      reaction = Reaction.new(r.attribute("name").to_s,
                              r.attribute("").to_s == "false")
      r.elements.each("listOfReactants/specieReference") do |r_sp|
        reaction.reactants.push([model.species[r_sp.attribute("specie").to_s], r_sp.attribute("stoichiometry")])
      end
      r.elements.each("listOfProducts/specieReference") do |r_sp|
        reaction.products.push([model.species[r_sp.attribute("specie").to_s], r_sp.attribute("stoichiometry")])
      end
      model.reactions.push(reaction)
    end

    def make_SPN(m, out)
      out.puts "digraph SPN {"
      tab = 3
      m.species.keys.each do |k|
        out.puts "%s \"%s\" [shape=circle];" % [" " * tab, k]
      end
      out.puts
      m.reactions.each do |r|
        out.puts "%s \"%s\" [shape=box]" % [" " * tab, r.name]
        r.reactants.each do |r_sp|
          out.puts "%s \"%s\" -> \"%s\" [label=\"%s\"];" % [" " * tab, r_sp[0].name, r.name, r_sp[1]]
        end
        out.puts
        r.products.each do |r_sp|
          out.puts "%s \"%s\" -> \"%s\"" % [" " * tab, r.name, r_sp[0].name]
        end
      end
      out.puts "}"
      out.close
    end

    make_SPN(model, open("test.dot", "w"))

    system("dot -Tps test.dot >out.eps")
  end
end
