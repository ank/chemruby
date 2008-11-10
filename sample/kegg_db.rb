
$: << 'lib'
$: << 'ext'
$: << '/home/tanaka/proj/sqliter/lib'
$: << '/home/tanaka/proj/sqliter/ext'

require 'sqliter'
require 'table'
require 'chem'

module Chem
  module Molecule
    include RRecord

    table_text "adj_matrix"
    table_text "filename"
    table_text "n_nodes", :method => "nodes.length"
    table_number "n_edges", :method => "edges.length"# table_number NOT IMPLEMENTED YET!!!
    table_number "n_carbonds", :method => "nodes.find_all{|node| node.element == :C}.length"
    table_number "n_nitrogens", :method => "nodes.find_all{|node| node.element == :N}.length"
    #table_number "n_carbons", :methods => "node_types."
    def node_types
      nodes.collect{|node| Element2Number[node.element]}
    end
  end
end


if false#true
  db = RDataBase.new("temp/test.db")
  table = db.new_table(Chem::Molecule)

  Dir["/home/tanaka/share/data/kegg/ligand/mol/C000*.mol"].each do |file|
    puts file
    next unless File.exist?(file)
    mol = Chem.open_mol(file)
    table.push(mol)
  end
else # search
  def find mol
    db = RDataBase.new("temp/test.db")
    stmt = db.prepare("select filename, adj_matrix, node_types from table0 where n_nodes = ? and n_edges = ?;")
    stmt.bind(mol.nodes.length.to_s, mol.edges.length.to_s)
  end
  query = Chem.open_mol("/home/tanaka/share/data/kegg/ligand/mol/C00147.mol")

  mols = find query
  mols.each do |filename, n_edges|
    p filename
  end
end


__END__
table.select(["n_nodes", "31"])

__END__

mol1 = 
mol2 = Chem.open_mol("/home/tanaka/share/data/kegg/ligand/mol/C%05d.mol" % 3)

p mol2.match_by_ullmann(mol1)

__END__

table = RTable.new(Chem::Molecule)

1.upto(10) do |n|
  file = "/home/tanaka/share/data/kegg/ligand/mol/C%05d.mol" % n
  next unless File.exist?(file)
  mol = Chem.open_mol(file)
  table.push(mol)
end

table.save("kegg.db")

__END__

# if true
#   p Chem.open_mol("/home/tanaka/share/data/kegg/ligand/mol/C03580.mol").match_by_ullmann($mol)
# end

# __END__

# open("false.txt").each do |line|
#   file = "/home/tanaka/share/data/kegg/ligand/mol/#{line.chop}.mol"
#   next unless File.exist?(file)
#   mol2 = Chem.open_mol(file)

#   puts "%s %3d %3d %s" % [line.chop, mol2.nodes.length, mol2.edges.length, mol2.match_by_ullmann($mol).inspect]
# end
# __END__


def check name
  file = "/home/tanaka/share/data/kegg/ligand/mol/#{name}.mol"
  return nil if !File.exist?(file)
  mol2 = Chem.open_mol(file)
  #mol.match_by_ullmann(mol2)
  mol2.match_by_ullmann($mol)
end

# check("C00040")

#__END__

open("false.txt", "w") do |out|
  %w(C00002 C00003 C00004 C00005 C00006 C00008 C00010 C00016 C00019 C00020 C00021 C00024 C00040 C00053 C00054 C00083 C00091 C00100 C00131 C00136 C00147 C00154 C00170 C00194 C00206 C00212 C00223 C00224 C00264 C00313 C00323 C00332 C00356 C00360 C00371 C00406 C00411 C00412 C00498 C00510 C00512 C00527 C00531 C00540 C00559 C00566 C00575 C00582 C00605 C00630 C00640 C00658 C00683 C00728 C00798 C00821 C00827 C00845 C00857 C00877 C00882 C00888 C00894 C00895 C00904 C00920 C00939 C00946 C00968 C01011 C01033 C01063 C01086 C01122 C01137 C01144 C01201 C01213 C01260 C01291 C01352 C01367 C01469 C01513 C01610 C01655 C01794 C01832 C01882 C01894 C01920 C01942 C01944 C02015 C02029 C02030 C02041 C02050 C02060 C02187 C02232 C02247 C02249 C02331 C02335 C02353 C02411 C02451 C02509 C02557 C02577 C02593 C02609 C02611 C02784 C02792 C02801 C02802 C02843 C02860 C02864 C02939 C02944 C02949 C02973 C03035 C03058 C03060 C03069 C03160 C03188 C03218 C03221 C03231 C03237 C03246 C03293 C03300 C03344 C03345 C03357 C03361 C03391 C03416 C03423 C03460 C03462 C03466 C03483 C03561 C03568 C03580 C03595 C03673 C03685 C03709 C03724 C03794 C03795 C03815 C03850 C03851 C03883 C04013 C04030 C04047 C04058 C04083 C04154 C04159 C04307 C04316 C04348 C04380 C04405 C04422 C04425 C04432 C04512 C04644 C04675 C04713 C04760 C04779 C04856 C04899 C05056 C05057 C05065 C05067 C05116 C05117 C05165 C05195 C05198 C05231 C05232 C05258 C05259 C05260 C05262 C05263 C05264 C05265 C05266 C05267 C05268 C05269 C05270 C05271 C05272 C05273 C05274 C05275 C05276 C05279 C05280 C05329 C05337 C05338 C05342 C05447 C05448 C05449 C05450 C05460 C05461 C05467 C05560 C05668 C05686 C05691 C05692 C05696 C05921 C05983 C05989 C05993 C05997 C05998 C06000 C06027 C06028 C06192 C06197 C06322 C06387 C06397 C06398 C06433 C06434 C06506 C06507 C06508 C06509 C06510 C06625 C06671 C06714 C06715 C06723 C06736 C06737 C06743 C06749 C07024 C07025 C07026 C07027 C07028 C07029 C07030 C07031 C07032 C07118 C07160 C07195 C07296 C07297 C07302 C07303 C07343 C07347 C07348 C07624 C08083 C08272 C08431 C08434 C08435 C09809 C09810 C09811 C09812 C09813 C09817 C09818 C09819 C09820 C09821 C09823 C09824 C09825 C11062 C11263 C11266 C11277 C11407 C11421 C11448 C11462 C11500 C11618 C11929 C11934 C11935 C11936 C11945 C11946 C11947 C11948 C11949 C12092 C12203).each do |name|
    result = check name
    unless result
      out.puts name
    end
    puts "%s %s" % [name, result.inspect]
  end
end

