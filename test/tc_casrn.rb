
require 'test/unit'

class CASRNTest < Test::Unit::TestCase

  def test_validity
    [
      ["aaa", false],
      ["107-07-3", true],
      ["107-07-4", false],
      ["aa-07-3", false],
    ].each do |casrn, test|
      assert_equal(casrn.is_valid_casrn?, test)
    end
  end

end
