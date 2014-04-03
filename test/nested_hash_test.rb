require 'test_helper'

describe "NestedHash" do
  let(:nested_hash) { NestedHash[a: {b: 1}, c: { d: {e: 2} }] }
  it 'should transform a nested hash correctly' do
    nested_hash2 = nested_hash.transform { |value| value + 1 }
    nested_hash2[:a][:b].must_equal 2
    nested_hash2[:c][:d][:e].must_equal 3
  end

  it 'should transform a nested hash with route correctly' do
    nested_hash2 = nested_hash.transform_with_route { |route, value|
      route.concat [value]
    }
    nested_hash2[:a][:b].must_equal [:a, :b, 1]
    nested_hash2[:c][:d][:e].must_equal [:c, :d, :e, 2]
  end

  it 'should map a nested hash correctly' do
    nested_hash2 = nested_hash.map_values { |value| value }
    nested_hash2.must_equal [1, 2]
  end

  it 'should map a nested hash with route correctly' do
    nested_hash2 = nested_hash.map_values_with_route { |route, value|
      route.concat [value]
    }
    nested_hash2.must_equal [[:a, :b, 1], [:c, :d, :e, 2]]
  end

end
