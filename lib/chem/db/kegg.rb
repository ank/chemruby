#
# = chem/db/kegg.rb - KEGG (Kyoto Encylopedia of Genes and Genomes)
#
# Author::	Nobuya Tanaka <t@chemruby.org>
#
# $Id:$
#

require 'chem/db/mdl'

module Chem
  class KEGGException < Exception
  end

  module KEGG

    CNUMREG = /C(\d\d\d\d\d)/
    ECREG   = /EC([^.]+)\.([^.]+)\.([^.]+)\.([^.]+)/
    @@kegg = {}

    def self.[](kegg_id)
      @@kegg[kegg_id] ||= case kegg_id
                         when CNUMREG
                         when ECREG
                           EC.new($1, $2, $3, $4)
                         else
                           raise KEGGException, "Unknown KEGG ID '#{kegg_id}'"
                         end
    end

    class Compound
    end

    class Reaction
    end

    module ReactionList
    end

    class EC

      def initialize(num1, num2, num3, num4)
        #puts Chem.data_dir
      end

    end

  class KeggDirectory

    attr_reader :dir
    def initialize dir
      @dir = dir
      @compounds = {}
      @ligand_dir = File.join(@dir, "ligand")
      @mol_dir = File.join(@ligand_dir, "mol")
      @parsed_file = []
    end

    def get_organism organism, file
      File.join(@dir, "genomes", organism, file)
    end

    def gene_to_pfam organism
      filename = File.join(@dir, "genomes", organism, organism + "_pfam.list")
      return @pfam2gene if @parsed_file.include?(filename)
      @parsed_file.push filename
      @gene2pfam ||= {}
      @pfam2gene ||= {}
      open(filename).each do |line|
        gene, pfam = line.split("\t")
        @gene2pfam[gene] = pfam.chop
        (@pfam2gene[pfam.chop] ||= []).push(KeggGene.new(gene, organism, self))
      end
      @pfam2gene
    end

    def get_ec_number gene
      @gene2enzyme ||= {}
      @enzyme2gene ||= {}
      filename = File.join(@dir, "genomes", gene.organism, gene.organism + "_enzyme.list")
      return @gene2enzyme[gene.gene] if @parsed_file.include?(filename)
      @parsed_file.push filename

      open(filename).each do |line|
        gn, ec = line.chop.split("\t")
        @gene2enzyme[gn] = ec
        @enzyme2gene[ec] = gn
      end
      @gene2enzyme[gene.gene]
    end

    def [](key)
      case key
      when /(R\d+)/
        get_reaction $1
      when /(C\d+)/
        get_compound $1
      when /pf:(.+)/
        KeggPfam.new($1, self)
      when /^([^:]{3,4}):(\d+)/
        # gene
        raise "Parser for Organism not implemented!"
      when /^([^:]{3,4})/
        # organism
        KeggOrganism.new($1, self)
      else
        raise "unknown KEGG key type : #{key}"
      end
    end

    def map_formula
      @reaction_map_formula = parse_reaction_map_formula unless @reaction_map_formula
      @reaction_map_formula
    end

    def parse_reaction_map_formula
      rxns = {}
      parser = Chem.parse_file(File.join(@dir, "ligand", "reaction_mapformula.lst"))
      parser.each do |rxn|
        rxns[rxn.entry] = rxn
      end
      rxns
    end

    # Private methods
    private
    class KeggOrganism
      
      def initialize organism, kegg
        @organism = organism
        @kegg = kegg
      end

      def pfam
        pfam2gene = @kegg.gene_to_pfam(@organism)
        pfam2gene
      end

      def [](key)
        @kegg
      end

    end

    private
    class KeggGene

      attr_reader :organism, :gene
      def initialize gene, organism, kegg
        @gene = gene
        @organism = organism
        @kegg = kegg
      end

      def ec_number
        @kegg.get_ec_number(self).inspect
      end

    end

    private
    class KeggPfam

      def initialize pfam_key, kegg
        @kegg = kegg
        @pfam_key = pfam_key
      end

      def [](organism)
        @kegg[organism][@pfam_key]
      end

    end

    private
    def get_compound name
      unless @compounds[name]
        @compounds[name] = Chem.open_mol(File.join(@dir, "ligand", "mol", name) + ".mol")
      end
      @compounds[name]
    end

    def get_reaction name
      @reactions ||= parse_reaction
      @reactions[name]
    end

    def parse_reaction
      rxns = {}
      parser = Chem.parse_file(File.join(@dir, "ligand", "reaction"))
      parser.each do |reaction|
        reaction.kegg = self
        rxns[reaction.entry] = reaction
      end
      rxns
    end

  end

  #obsolete
    @@kegg_compound_folder = nil
    def self.kegg_compound_folder= (folder)
      @@kegg_compound_folder = folder
    end

    def self.kegg_compound_folder
      @@kegg_compound_folder
    end

    # Duplication definition!
    class KEGGReaction

      include Chem::Reaction
      attr_accessor :entry, :name, :ecs, :compounds, :direction
      def initialize
        @ecs = []
        @compounds = []
      end

      def kegg= kegg
        @kegg = kegg
      end

      def map_formula
        return nil unless @kegg.map_formula[@entry]
        @kegg.map_formula[@entry].compounds
      end
    end

    class KeggCompound
      include Molecule
      include Enumerable
      include MDL::MdlMolParser
      attr_reader :entry

      def initialize
        @nodes = []
        @edges = []
      end

      @@entries = {}
      def entry= entry_no
        @entry = entry_no
        if @@entries[entry_no] == nil
          if Chem::Kegg.kegg_compound_folder == nil
            raise ArgumentError.new("Chem::Kegg.kegg_compound_folder" +
                                      " not specified")
          end
#           mol = KeggCompound.new
#           mol.open(Chem::Kegg.kegg_compound_folder + entry_no + ".mol")
          filename = File.join(Chem::Kegg.kegg_compound_folder, entry_no + ".mol")
          mol = nil
          if File.exist?(filename)
            mol = Chem.open_mol(filename)
          end

          @@entries[entry_no] = mol
        end
        @fly_weight = @@entries[entry_no]
        if @fly_weight
          @nodes = @fly_weight.nodes
          @edges = @fly_weight.edges
        end
      end

    end

    class KeggGlycan
      attr_accessor :entry, :name
    end

    class KeggEc
      attr_accessor :entry, :number
    end

    module KeggFormat

      def compound_folder= (folder)
        Chem::Kegg.kegg_compound_folder = folder
      end

      def each_entry
        state = nil
        str = ''
        @input.each do |line|
          if line[0..11] == '            '
            str += line[12..-1]
          else
            yield(str, state) if state # Not first state
            str = line[12..-1]
            state = line[0..11].strip
          end
        end
      end
    end

    class KeggReactionParser

      include KeggFormat
      include Enumerable

      def initialize filename
        @input = File.open(filename)
      end

      def parse_compounds species
        ary = []
        species.split(" + ").each do |mol|
          stoichiometry = 1
          if m = /(\d+) *[CG]/.match(mol)
            stoichiometry = m[1].to_i
          end
          compound_entry = ""
          if m = /(C\d+)/.match(mol)
            compound_entry = m[1]
          elsif m = /(G\d+)/.match(mol)
            compound_entry = m[1]
          end
          ary.push([compound_entry, stoichiometry])
        end
        ary
      end

      def each
        reaction = nil
        each_entry do |str, state|
          case state
          when "ENTRY"
#          reaction = Reaction.find(:first, :conditions => ["entry = ?", str.split[0]])
#            if reaction == nil
            reaction = KEGGReaction.new
            reaction.entry = str.split[0]
#          end
          when "NAME"
            reaction.name = str
          when "DEFINITION"
            #@definition = str
          when "EQUATION"
            c = str.split("<=>")
            reaction.compounds << parse_compounds(c[0])
            reaction.compounds << parse_compounds(c[1])
          when "RPAIR"
            # @rpair = str
          when "ENZYME"
            str.split.each do |e|
              ec = KeggEc.new
              ec.entry = "EC" + e
              sp = e.split(".")
              ec.number = sp.collect{|i| i.to_i}
              reaction.ecs << ec
            end
          when "///"
            #          reaction.save
            yield reaction
          when "PATHWAY"
          when "COMMENT"
          when "REFERENCE"
          else
            p state
          end
        end
      end

    end

    class KeggReactionLstParser

      include Enumerable
      include KeggFormat

      def initialize filename
        @input = open(filename)
      end
      
      def each
        @input.each do |line|
          rxn = KEGGReaction.new
          r_number, comps = line.split(":")
          rxn.entry = r_number
          cc = comps.split(/<=>/)

          reactant = cc[0].split("+").collect do |c|
            ary = c.split
            #compound = KeggCompound.new
            if ary.length == 1
              #compound.entry = c.strip
              [c.strip, 1]
            else
              #compound.entry = ary[1].strip
              [c.strip, ary[0].to_i]
            end
          end
          product = cc[1].split("+").collect do |c|
            ary = c.split
            #compound = KeggCompound.new
            if ary.length == 1
              #compound.entry = c.strip
              [c.strip, 1]
            else
              #compound.entry = ary[1].strip
              [c.strip, ary[0].to_i]
            end
          end
          rxn.compounds = [reactant, product]
          yield rxn
        end
        
      end

    end

    # ftp://ftp.genome.ad.jp/pub/kegg/ligand/reaction_mapformula.lst
    class KeggReactionMapParser

      include Enumerable
      include KeggFormat

      def initialize filename
        @input = open(filename)
        @reactions = @input.inject({}) do |ret, line|
          ary = line.split(":")
          ret[ary[0]] = ary[1..-1]
          ret
        end
      end

      def each
        @reactions.each do |r_number, (map_number, comps)|
          yield self[r_number]
        end
      end

      def [](r_number)
        return nil if @reactions[r_number] == nil
        map_number, comps = @reactions[r_number]
        rxn = KEGGReaction.new
        #          r_number, map_number, comps = line.split(":")
        rxn.entry = r_number
        cc = comps.split(/(<?=>?)/)
        case cc[1]
        when "<="
          rxn.direction = -1
        when "<=>"
          rxn.direction = 0
        when "=>"
          rxn.direction = 1
        end
        reactant = cc[0].split("+").collect do |c|
          #compound = KeggCompound.new
          #compound.entry = c.strip
          [c.strip, 1]
        end
        product = cc[2].split("+").collect do |c|
          #compound = KeggCompound.new
          #compound.entry = c.strip
          [c.strip, 1]
        end
        rxn.compounds = [reactant, product]
        rxn
      end

    end

    # Parses KEGG Glycan format
    # http://www.genome.jp/ligand/kcam/kcam/kcf.html
    # Not fully implemented
    class KeggGlycanParser

      include Enumerable
      include KeggFormat

      def initialize filename
        @input = open(filename)
      end

      def each
        glycan = nil
        each_entry do |str, state|
          case state
          when "ENTRY"
            glycan = KeggGlycan.new
#            glycan = Compound.find(:first, :conditions => ["glycan_entry = ?", str.split[0]])
            if glycan == nil
#              glycan = Compound.new
              glycan.entry = str.split[0]
            end
          when "NAME"
            if glycan.name
              glycan.name = glycan.name + str.split("\n").join if str
            else
              glycan.name = str.split("\n").join if str
            end
          when "///"
            #          glycan.save
          end
        end
      end

    end

    def self.parse_compound_file
      compound = nil
      parse($home + "compound") do |str, state|
        case state
        when "ENTRY"
          compound = Compound.find(:first, :conditions => ["entry = ?", str.split[0]])
          if compound == nil
            compound = Compound.new
            compound.entry = str.split[0]
          end
        when "NAME"
          compound.name = str.split("\n").join if str
        when "DBLINKS"
          str.split("\n").each do |line|
            if m = /ChEBI: (\d+)/.match(line)
              compound.chebi = m[1].to_i
            elsif m = /PubChem: (\d+)/.match(line)
              compound.pubchem = m[1].to_i
            end
          end
        when "GLYCAN"
          compound.glycan_entry = str
        when "///"
          #compound.save
        end
      end
    end

    def set_compounds
      require 'util'
      Dir.glob($home + "/mol/*.mol").each do |mol|
        entry = /(.\d+).mol/.match(mol)[1]
#        comp = KeggCompound.find(:first, :conditions => ["entry = ?", entry])
        mol = Chem.open_mol(mol)
        if comp == nil
          puts mol
          next
        end
        if comp.ctab == nil
          comp.ctab = Marshal.dump(mol)
          comp.save
        end
        #p comp
      end
    end

  end
end


