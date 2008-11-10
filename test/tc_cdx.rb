#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_cdx.rb 149 2006-02-08 08:02:33Z tanaka $
#

require 'test/all'

require 'test/type_test'
require 'test/ctab_test'
require 'test/coord_test'

require 'chem'

class CDXTest < Test::Unit::TestCase

  include Chem::TypeTest
  include Chem::CtabTest
  include Chem::CoordTest

  def setup
    @entries = Chem.open_mol($data_dir + "hypericin.cdx")
    @parser = Chem::CDX
    @file_type = Chem::Type::CdxType
  end

  def test_false
    assert(true)
  end

end
