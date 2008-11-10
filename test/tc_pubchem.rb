

class PubChemTest < Test::Unit::TestCase

  def test_pubchem_subskeys
    mol = Chem.open_mol(File.join($data_dir, "CID_704.sdf")).to_a[0]
    original = mol.pubchem_subskeys
    assert_equal("11000000001111011100111000000111", ("%b" % original)[-32..-1])
    pos = mol.pubchem_subskeys.to_bit_positions
    assert_equal([0, 1, 2, 9, 10, 11, 14, 15, 16, 18, 19, 20, 21], pos[0..12])
    gen_sk = mol.generate_pubchem_subskey

    # Test for Section 1
    assert_equal(("%0881b" % original)[-114..-1], ("%0881b" % gen_sk)[-114..-1])
    # Test for Section 2
    pos.each do |n|
      puts Chem::PubChemSubsKey[n] if n > 115 and n < 262
    end
    pos2 = gen_sk.to_bit_positions
    pos2.each do |n|
      puts Chem::PubChemSubsKey[n] if n > 115 and n < 262
    end
    p mol.generate_pubchem_subskey.to_bit_positions
    p pos
  end

  def test_path_fingerprint
    fp = Chem.open_mol(File.join($data_dir, "hypericin.mol")).fingerprint(7, 32)
    assert_operator(32, :<, fp)
  end

end
