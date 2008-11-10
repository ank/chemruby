
MolDir = "/home/tanaka/data/kegg/ligand/mol/C%05d.mol"

class DevelopmentTest < Test::Unit::TestCase

  def test_net
    # p Chem.search("pparg", :db => :pubmed)
    # search adenine
    res = Chem.search("CCC", :db => :pubchem)
#    res = Chem.search("C1=NC2=C(N1)C(=NC=N2)N", :db => :pubchem)
    sleep 3
    res.fetch_all
    #res.retrieve
  end

end

__END__

class PendingTest < Test::Unit::TestCase

  def test_raise
    BitDatabase.new("temp/test.fng", 80) do |db|
      assert_raise(Exception){ db.push([81]) }
      db.push([24, 30, 32, 55])
    end
  end

  def test_fingerprint
    BitDatabase.open("temp/test2.fng", 80) do |db|
      db.push([24, 30, 31, 32, 55])
      assert(true)
    end

    BitDatabase.search("temp/test2.fng", [24, 30, 55])
  end

end
