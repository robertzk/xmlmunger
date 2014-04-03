require 'test/unit'
require 'xmlmunger'

class ParserTest < Test::Unit::TestCase

  def test_simple_nested_parse
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run
    assert_equal hash, {"x_y"=>"1", "x_z"=>"2"}
  end

  def test_filter_option
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run(filter: [:x])
    assert_equal hash, {"y"=>"1", "z"=>"2"}
  end

  def test_prefix_option
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run(prefix: 'test_')
    assert_equal hash, {"test_x_y"=>"1", "test_x_z"=>"2"}
  end

end

