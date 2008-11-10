#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_iupac.rb 127 2006-02-03 02:47:57Z tanaka $
#

require 'chem/db/iupac'

require 'test/all'
require 'test/ctab_test'

class IupacTest < Test::Unit::TestCase

  def setup
    @parser = IupacParser.new
  end

  def test_a_1
    ["3-Methylpentane",
     "2,3,5-Trimethylhexane",
     "Isopropyl",
     "7-(1,2-Dimethylpentyl)-5-ethyltridecane",
     "7,7-Bis(2,4-dimethylhexyl)-3-ethyl-5,9,11-trimethyltridecane",
    ]
    ["hexane",
     "hexylhexane", # Invalid IUPAC name
     "1,2-dihexylhexane", # Invalid IUPAC name
     "5-Methyl-6-propylnonane",
#     "6-(1-methylbutyl)-8-(2-methylbutyl)tridecane",
    ].each do |name|
      @parser.parse(name)
    end
    assert(true)
  end
end
