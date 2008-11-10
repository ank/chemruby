require 'chem'

class RMagickTest < Test::Unit::TestCase

  def setup
  end

  def test_rmagick
    mol = Chem.open_mol($data_dir + "hypericin.mol")
    mol.nodes.each{|node| node.visible = true unless node.element == :C}
    mol.save(File.join(%w(temp save_test.png)))

  end

end
