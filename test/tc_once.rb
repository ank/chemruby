require 'chem'

class Foo

  include Once

  def initialize
    @value = 0
  end

  def get
    @value += 1
    @value
  end

  once :get

end

class OnceTest < Test::Unit::TestCase

  def test_once
    foo = Foo.new
    assert_equal(1, foo.get)
    assert_equal(1, foo.get)
    assert_equal(1, foo.get)
  end

end
