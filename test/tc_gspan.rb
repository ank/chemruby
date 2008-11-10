
require 'test/all'

require 'test/type_test'
require 'test/ctab_test'
require 'test/coord_test'

require 'chem'

class GSpanTest < Test::Unit::TestCase

  include Chem::CtabTest

  def setup
    (@entries = []).push(Chem::GSpan.parse("(6) 0 (0f6) 0 (1f6) 0 (2f6) 0 (3f6) 0 (4f8) 0 (1f6)"))
    @entries.push Chem::GSpan.parse("(6) 0 (0f6) 0 (1f6) 0 (2f6) 0 (3f6) 0 (4f6) 0 (b0) 0 (5f6) 0 (6f8) 0 (4f6)")
    @parser = Chem::GSpan
  end

  def test_gspan
    mols = []
    mols.push(Chem.open_mol($data_dir + "hypericin.mol"))
    mols.push(Chem.open_mol($data_dir + "cyclohexane.mol"))
    Chem.save(mols, File.join(%w(temp temp.fp)))
  end


end
