

require 'test/all'

require 'test/type_test'
require 'test/ctab_test'
require 'test/coord_test'

require 'chem'

class KCFTest < Test::Unit::TestCase

  include Chem::TypeTest
  include Chem::CtabTest
  include Chem::CoordTest

  def setup
    (@entries = []).push(Chem.open_mol($data_dir + "C00147.kcf"))
    require 'chem/db/kcf'
    @parser = Chem::KEGG::KCF
    @file_type = Chem::Type::KCFType
  end

end
