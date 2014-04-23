require 'test/unit'
require 'xmlmunger'

class ParserTest < Test::Unit::TestCase

  def test_simple_nested_parse
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run
    assert_equal({"x_y"=>"1", "x_z"=>"2"}, hash)
  end

  def test_filter_option
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run(filter: [:x])
    assert_equal({"y"=>"1", "z"=>"2"}, hash)
  end

  def test_prefix_option
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run(prefix: 'test_')
    assert_equal({"test_x_y"=>"1", "test_x_z"=>"2"}, hash)
  end

  def test_sep_option
    parser = ::XMLMunger::Parser.new('<x><y>1</y><z>2</z></x>')
    hash = parser.run(sep: '-')
    assert_equal({"x-y"=>"1", "x-z"=>"2"}, hash)
  end

  def test_prohibited_types_option
    parser = ::XMLMunger::Parser.new('<x><y><z>1</z><z>1</z></y><z>2</z></x>')
    hash = parser.run(prohibited_types: [Array])
    assert_equal({"x_z"=>"2"}, hash)
  end

  def test_strip_chars_option
    parser = ::XMLMunger::Parser.new('<x_y><z_w>2</z_w></x_y>')
    hash = parser.run(strip_chars: '_')
    assert_equal({"xy_zw" => "2"}, hash)
  end

  def test_attributes_option
    parser = ::XMLMunger::Parser.new('<x a="1" />')
    hash = parser.run(attributes: true)
    assert_equal({"x_@a" => "1"}, hash)
    hash = parser.run(attributes: false)
    assert_equal({}, hash)
    hash = parser.run(attributes: true, strip_chars: '@')
    assert_equal({"x_a" => "1"}, hash)
    hash = parser.run(attributes: false, strip_chars: '@')
    assert_equal({}, hash)
  end



end

