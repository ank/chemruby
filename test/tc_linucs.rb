#
# test_adj.rb - Test for adjacency
#
#
# $Id: test_linucs.rb 127 2006-02-03 02:47:57Z tanaka $
#

require 'test/all'

require 'chem'
require 'chem/db/linucs/linparser'

class LinucsTest < Test::Unit::TestCase

  def test_linucs
    assert(true)
#     parser = LinucsParser.new
#     parser.parse("[][Asn]{[(4+1)][b-D-GlcpNAc]{[(4+1)][b-D-GlcpNAc]{[(4+1)][b-D-Manp]{[(3+1)][a-D-Manp]{[(2+1)][a-D-Manp]{[(2+1)][a-D-Manp]{}}}[(6+1)][a-D-Manp]{[(3+1)][a-D-Manp]{[(2+1)][a-D-Manp]{}}[(6+1)][a-D-Manp]{[(2+1)][a-D-Manp]{}}}}}}}")
  end

end
