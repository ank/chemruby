# $Id: test_mdl.rb 84 2005-12-01 10:01:04Z tanaka $

# Tests to ensure functionality

#require 'all'

#require 'type_test'
#require 'ctab_test'
#require 'coord_test'

require 'test/unit'
$data_dir =  File.join(File.dirname(File.expand_path(__FILE__)), "/data/")
require 'chem'

class SybylTest < Test::Unit::TestCase

#  include Chem::TypeTest
#  include Chem::CtabTest
#  include Chem::CoordTest

  def setup
	Chem.open_mol($data_dir + "hypericin.mol2")
    #(@entries = []).push(Chem.open_mol($data_dir + "hypericin.mol2"))
    @parser = Chem::Sybyl::SybylMolecule
 #   @file_type = Chem::Type::SybylType
  end

  def test_mol

  end

end
