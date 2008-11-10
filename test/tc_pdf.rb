
require 'chem'

class PDFTest < Test::Unit::TestCase

  def test_pdf
    mol = Chem.open_mol($data_dir + "hypericin.mol")
    mol.nodes.each{|node| node.visible = true unless node.element == :C}
    Chem.save(mol, File.join(%w(temp temp.pdf)))
  end

end
