# $Id: test_sub.rb 65 2005-10-25 17:17:36Z tanaka $

require 'chem'

require 'test/all'

class SubTest < Test::Unit::TestCase

  def setup
    @cyclohexane = Chem.open_mol($data_dir + 'cyclohexane.mol')
  end

  def test_induced_subgraph
    sub = @cyclohexane.induced_sub(@cyclohexane.nodes[0..2])
    assert_equal(sub.nodes.length, 3)
  end

  def test_minus
    sub = @cyclohexane.induced_sub(@cyclohexane.nodes[0..2])
    sub2 = @cyclohexane - sub
    assert_equal(sub2.nodes.length, 3)
  end

  def test_connection
    mol = Chem.parse_smiles("CCCC.NNNNN")
    mol2 = Chem.parse_smiles("CCCCNNNNN")
    assert_equal(false, mol.connected?)
    assert(mol2.connected?)
  end

  def test_divide
    mol = Chem.parse_smiles("CC.N1NN1.OOOO")
    ary = mol.divide
    ary.each do |mol|
      case mol.nodes[0].element
      when :C
        assert_equal(2, mol.nodes.length)
      when :N
        assert_equal(3, mol.nodes.length)
      when :O
        assert_equal(4, mol.nodes.length)
      end
    end
  end

end

