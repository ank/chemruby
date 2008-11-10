#
# test_kegg.rb - Test for KEGG
#
#
# $Id: test_kegg.rb 151 2006-02-08 08:21:08Z tanaka $
#

require 'test/all'
require 'test/multiple_test'
require 'test/type_test'

require 'chem/db/kegg'

class KeggOpenTest < Test::Unit::TestCase

  def test_coc
    Chem::KEGG["C00147"]
    assert_instance_of(Chem::KEGG::EC, Chem::KEGG["EC1.2.3.4"], "EC1.2.3.4")
    assert_instance_of(Chem::KEGG::EC, Chem::KEGG["EC1.2.3.*"], "EC1.2.3.*")
    assert_instance_of(Chem::KEGG::EC, Chem::KEGG["EC10.20.30.*"], "EC10.20.30.*")
    assert_raises(Chem::KEGGException){
      Chem::KEGG["Unknown"]
    }
    assert_raises(Chem::KEGGException){
      Chem::KEGG["EC1"]
    }
  end

  def test_open
    # environment dependent test!
    #dir = "/home/tanaka/share/data/kegg"
    kegg = Chem.open_kegg(File.join($data_dir, "kegg"))

    compound = kegg["C00147"]
    assert(10, compound.nodes.length)
    assert(11, compound.edges.length)

    reaction = kegg["R00001"]
    assert_not_nil(reaction)
    assert_equal([[["C00147", 1]], [["C00009", 1]]], reaction.map_formula)

    m_formula = reaction.map_formula
    compound = kegg[m_formula[0][0][0]]
    assert_not_nil(compound)
    assert_equal(10, compound.nodes.length)

  end

end


__END__
#obsolete
Chem::Kegg.kegg_compound_folder = $data_dir

class KeggReactionTest < Test::Unit::TestCase

  include Chem::MultipleTest
  include Chem::TypeTest

  def setup
    @entries   = Chem.parse_file(File.join($data_dir, "kegg", "ligand", "reaction"))
    @parser    = Chem::Kegg::KeggReactionParser
    @file_type = Chem::KeggReactionType
  end

  def test_entry
    @entries.each do |entry|
      assert_respond_to(entry, :entry)
    end
  end

end

class KeggReactionLstTest < Test::Unit::TestCase

  include Chem::MultipleTest
  include Chem::TypeTest

  def setup
    @entries   = Chem.open_mol(File.join($data_dir, "kegg", "ligand", "reaction.lst"))
    @parser    = Chem::Kegg::KeggReactionLstParser
    @file_type = Chem::KeggReactionLstType
  end

  def test_entry
    @entries.each do |rxn|
      assert_equal("2 C00890", rxn.compounds[0][0][0])
    end
  end

end

class KeggReactionMapTest < Test::Unit::TestCase
  include Chem::MultipleTest
  include Chem::TypeTest

  def setup
    @entries = Chem.open_mol(File.join($data_dir, "kegg", "ligand", "reaction_mapformula.lst"))
    @parser = Chem::Kegg::KeggReactionMapParser
    @file_type = Chem::KeggReactionMapType
  end

end

class KeggGlycanTest < Test::Unit::TestCase

  include Chem::MultipleTest
  include Chem::TypeTest

  def setup
    @entries = Chem.open_mol(File.join($data_dir, "glycan"))
    @parser = Chem::Kegg::KeggGlycanParser
    @file_type = Chem::KeggGlycanType
  end

end

class KeggPfamTest < Test::Unit::TestCase

  def test_false
    kegg = Chem.open_kegg(File.join($data_dir, "kegg"))
    cadherin = kegg["pf:Cadherin"]
    assert_not_nil(cadherin)
    gene = cadherin["hsa"]
    human = kegg["hsa"]
    assert_not_nil(gene)
  end

end

