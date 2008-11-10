# $Id: test_mdl.rb 151 2006-02-08 08:21:08Z tanaka $

# Tests to ensure functionality

require 'test/all'

require 'test/type_test'
require 'test/ctab_test'
require 'test/coord_test'

require 'chem'

class MDLTest < Test::Unit::TestCase

  include Chem::TypeTest
  include Chem::CtabTest
  include Chem::CoordTest

  def setup
    (@entries = []).push(Chem.open_mol($data_dir + "hypericin.mol"))
    @parser = Chem::MDL::MdlMolecule
    @file_type = Chem::Type::MdlMolType
  end

  def test_to_mdl
    @entries[0].save(File.join(%w(temp save_test.mol)))
  end

  def test_bond_stereo
    mol = Chem.open_mol($data_dir + "atp.mol")
    types = mol.edges.inject({}){|ret, (b, a1, a2)| ret[b.stereo] ||= 0 ; ret[b.stereo] += 1 ; ret}
    assert_equal(2, types[:down])
    assert_equal(2, types[:up])
    assert_equal(29, types[:not_stereo])
  end

  def test_bond_type
    mol = Chem.open_mol($data_dir + "atp.mol")
    types = mol.edges.inject({}){|ret, (b, a1, a2)| ret[b.bond_type] ||= 0 ; ret[b.bond_type] += 1 ; ret}
    assert_equal(7,  types[:double])
    assert_equal(26, types[:single])
  end

  def test_mdl_header
    #  -ISIS-  02070623502D
    mol = Chem.open_mol($data_dir + "atp.mol")
    assert_equal("-ISIS-  ", mol.program_name)
    assert_equal(DateTime.new(2006, 2, 7, 23, 50), mol.date_time)
    assert_equal("2D", mol.dimensional_codes)
  end

  def test_save_mdl
    mol = Chem.open_mol($data_dir + "atp.mol")
    mol.save(File.join("temp", "save_test.mol"))
    now = DateTime.now
    mol = Chem.open_mol(File.join(%w(temp save_test.mol)))
    assert_equal(now.year,  mol.date_time.year)
    assert_equal(now.mday,  mol.date_time.mday)
    assert_equal(now.month, mol.date_time.month)
    assert_equal(now.hour,  mol.date_time.hour)
    assert_equal(now.min,   mol.date_time.min)
  end

end

