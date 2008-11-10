class OpenBabelTest < Test::Unit::TestCase

  def test_chemruby_ob_conversion
    mol = SMILES("CCC")
    assert_raise(NoMethodError) do
      mol.get_mol_wt # OBMol method
    end
    mol.use_open_babel
    assert_in_delta(44.09562, mol.get_mol_wt, 1.0)
  end

  def test_smiles
    mol = Chem::OpenBabel::parse_smiles("CCC")
    assert_in_delta(44.09562, mol.get_mol_wt, 1.0)
    assert_equal(3, mol.num_atoms)
    assert_equal(2, mol.num_bonds)
    mol.nodes.each do |atom|
      assert_not_nil(atom)
      assert_in_delta(12.0, atom.get_atomic_mass, 0.5)
    end
  end

  # example from:
  # http://depth-first.com/articles/2006/10/31/obruby-a-ruby-interface-to-open-babel
  def test_smarts
    smiles = 'CC(C)CCCC(C)C1CCC2C1(CCC3C2CC=C4C3(CCC(C4)O)C)C'
    mol = Chem::OpenBabel::parse_smiles(smiles)
    pat = Chem::OpenBabel::parse_smarts('C1CCCCC1')
    assert(pat.match(mol), "must match")
    ary = pat.get_umap_list
    assert_equal([12, 17, 16, 15, 14, 13], ary[0])
    assert_equal([20, 25, 24, 23, 22, 21], ary[1])
  end

  def test_load_sdf
    sdf = Chem::OpenBabel::load_sdf($data_dir + "CID_704.sdf")
    assert_equal(1, sdf.length)
  end

  def test_load_ob_save_ob
    mol = Chem::OpenBabel::load_as($data_dir + "hypericin.mol", "mdl")
    mol.ob_save_as("aa.fpt", "fpt")
  end

  def test_load_cr_save_ob
    Chem.load($data_dir + "hypericin.mol").ob_save_as("aa.mol", "mdl")
  end

  def test_export_as
    assert_not_nil(Chem.load($data_dir + "hypericin.mol").ob_export_as("inchi"))
  end

  def test_inchi
    assert_not_nil(Chem.load($data_dir + "hypericin.mol").to_inchi)
  end

end
