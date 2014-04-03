require 'test/unit'
require 'xmlmunger'

class NestedHashTest < Test::Unit::TestCase

  def nested_hash
    NestedHash[a: {b: 1}, c: { d: {e: 2} }] 
  end

  def transform_nested_hash
    nested_hash2 = nested_hash.transform { |value| value + 1 }
    assert_equal nested_hash2[:a][:b], 2
    assert_equal nested_hash2[:c][:d][:e], 3
  end

  def transform_nested_hash_with_route
    nested_hash2 = nested_hash.transform_with_route { |route, value|
      route.concat [value]
    }
    assert_equal nested_hash2[:a][:b], [:a, :b, 1]
    assert_equal nested_hash2[:c][:d][:e], [:c, :d, :e, 2]
  end

  def map_nested_hash
    nested_hash2 = nested_hash.map_values { |value| value }
    assert_equal nested_hash2, [1, 2]
  end

  def map_nested_hash_with_route
    nested_hash2 = nested_hash.map_values_with_route { |route, value|
      route.concat [value]
    }
    assert_equal nested_hash2, [[:a, :b, 1], [:c, :d, :e, 2]]
  end

end

