require 'test/unit'
require 'xmlmunger'

class ParserTest < Test::Unit::TestCase

  def test_simple_nested_parse
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run
    assert_equal hash, {"x_y"=>"1", "x_z"=>"2"}
  end

end

