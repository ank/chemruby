# $Id: test_subcomp.rb 160 2006-02-14 06:49:37Z tanaka $

require 'test/unit'
require 'test/all'

require 'chem'

class SubcompTest < Test::Unit::TestCase


  def test_bit_matrix
    [
      [31, 1],
      [32, 1],
      [33, 2],
      [63, 2],
      [64, 2],
      [65, 3],
    ].each do |bits, bytes|
      assert_equal(bytes, Chem::BitMatrix.new(bits, bits).n_bytes)
    end

    bm = Chem::BitMatrix.new(40, 40)
    0.upto(39) do |n|
      bm.set(n, n)
    end
  end

  def test_db_store
#     db = Chem::CompoundDB.new("test")

#     1.upto(10) do |n|
#       filename = MolDir % n
#       next if not File.exist?(filename)
#       mol = Chem.open_mol(filename)
#       db_id = db.store(mol)
#       puts db_id
#     end
    
#     db.close

#     assert_raises(Exception) do
#       Chem.db_search("Unexpectedly_Very_Long_File_Name_So_Please_Please_Raise_Error_Or_Program_will_Cause_Memory_Leak_It_Could_Be_Serious_Security_Problem", nil)
#     end

#     query  = Chem.open_mol(MolDir % 147)
#     Chem.db_search("test", query) # { |mol|  puts "found : %d" % mol }

#     target = Chem.open_mol(MolDir % 4307)
#     hash = query.match(target){ |q, t|
#       q.element == t.element
#       false
#     }
#     p hash
    # p Chem.match_by_ullmann(query, target)
  end

end

