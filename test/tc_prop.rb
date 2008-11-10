# $Id: test_prop.rb 73 2005-11-16 09:16:15Z tanaka $

require 'test/all'

require 'chem'

class PropTest < Test::Unit::TestCase

  def test_electro_negativity
    assert_equal(3.16, SMILES("Cl").nodes[0].electro_negativity)
  end

  def test_natural_bond_order
    assert_equal(4, SMILES("C").nodes[0].natural_bond_order)
    assert_equal(3, SMILES("N").nodes[0].natural_bond_order)
  end

  def test_oxidation_number
    mgcl2 = SMILES("Cl[Mg]Cl")
    mg = mgcl2.nodes.find{|n| n.element == :Mg}
    assert(2, mgcl2.oxidation_number(mg))

    get_en = lambda{|smiles|
      mol = SMILES(smiles)
      c = mol.nodes.find{|atom| atom.element == :C}
      mol.oxidation_number(c)
    }
    assert_equal(-4, get_en.call("HC(H)(H)H"))
    assert_equal(-2, get_en.call("HC(H)(H)F"))
    assert_equal(0, get_en.call("HC(H)(F)F"))
    assert_equal(-2, get_en.call("HC(H)(H)OH"))
    assert_equal(0, get_en.call("HC(H)=O"))
    assert_equal(2, get_en.call("HC(=O)OH"))
    assert_equal(4, get_en.call("O=C=O"))

    # implicit hydrogen atom
    assert_equal(-4, get_en.call("C"))
    assert_equal(2, get_en.call("C(=O)O"))
    # partially implicit
    assert_equal(0, get_en.call("C(H)(F)F"))
    
  end

  def test_n_hydrogen
    ch4 = SMILES("C")
    assert_equal(4, ch4.n_hydrogen(ch4.nodes[0]))
    hcooh = SMILES("C(=O)O")
    c = hcooh.nodes.find{|n| n.element == :C}
    assert_equal(1, hcooh.n_hydrogen(c))
  end

  def test_composition
    comp = Chem.open_mol($data_dir + "rxn/C01010.mol").composition
    assert_equal(2, comp[:C])
    assert_equal(2, comp[:N])
    assert_equal(3, comp[:O])
  end

  # return     1 if self.composition >  to.composition
  # return     0 if self.composition == to.composition
  # return    -1 if self.composition <  to.composition
  # return false if self.composition <> to.composition
  def test_subset_in_composition
    comp1 = Chem.parse_smiles("CCNOC")
    comp2 = Chem.parse_smiles("CCCCC")
    comp3 = Chem.parse_smiles("CNOCC")
    comp4 = Chem.parse_smiles("CNOC")
    comp5 = Chem.parse_smiles("CCC")
    comp6 = Chem.parse_smiles("CNNOC")
    comp7 = Chem.parse_smiles("ClOO")

    # different species
    assert_equal(false, comp2.subset_in_composition?(comp3))
    assert_equal(false, comp7.subset_in_composition?(comp1))
    assert_equal(1, comp3.subset_in_composition?(comp5))
    assert_equal(-1, comp5.subset_in_composition?(comp3))

    # same species
    assert_equal(0, comp1.subset_in_composition?(comp3))
    assert_equal(1, comp3.subset_in_composition?(comp4))
    assert_equal(-1, comp4.subset_in_composition?(comp3))
    assert_equal(false, comp3.subset_in_composition?(comp6))

  end

end
