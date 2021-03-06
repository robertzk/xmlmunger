module XMLMunger

  class NestedHash < Hash
    #######
    # Don't lose class type
    #######
    (Hash.instance_methods - Object.instance_methods).each do |m|
      define_method(m) { |*args, &block|
        result = super(*args, &block)
        return NestedHash[result] if result.class == Hash
        result
      }
    end

    #######
    # Map terminal hash values in a nested hash
    # > nh = NestedHash[a: { c: 2 }, b: 1]
    # => { a: { c: 2 }, b: 1 }
    # > nh.transform { |value| value + 1 }
    # => { a: { c: 3 }, b: 2 }
    #######
    def transform(&block)
      # http://stackoverflow.com/questions/5189161/changing-every-value-in-a-hash-in-ruby
      NestedHash[self.map { |key, value|
        [key, case value.class.to_s
          when 'Hash', 'NestedHash' then NestedHash[value].transform(&block)
          else yield value
        end]
      }]
    end

    #######
    # Map terminal hash values in a nested hash *with* route tracking
    # > nh = NestedHash[a: { c: 2 }, b: 1]
    # => { a: { c: 2 }, b: 1 }
    # > nh.transform_with_route { |route, value| "#{route.join(' -> ')} -> #{value}" }
    # => { a: { c: "a -> c -> 2" }, b: "b -> 1" }
    #######
    def transform_with_route(route = [], &block)
      NestedHash[self.map { |key, value|
        [key, case value.class.to_s
          when 'Hash', 'NestedHash' then
            NestedHash[value].transform_with_route(route.dup.concat([key]), &block)
          else yield route.dup.concat([key]), value
        end]
      }]
    end

    #######
    # Map terminal hash values in a nested hash to an array
    # > nh = NestedHash[a: { c: 2 }, b: 1]
    # => { a: { c: 2 }, b: 1 }
    # > nh.map_values
    # => [2, 1]
    # > nh.map_values { |x| x + 1 }
    # => [3, 2]
    #######
    def map_values(&block)
      values = []
      self.each { |key, value|
        values.concat case value.class.to_s
          when 'Hash', 'NestedHash' then NestedHash[value].map_values(&block)
          else [block_given? ? yield(value) : value]
        end
      }
      values
    end

    #######
    # Map terminal hash values in a nested hash to an array *with* route tracking
    # > nh = NestedHash[a: { c: 2 }, b: 1]
    # => { a: { c: 2 }, b: 1 }
    # > nh.map_values_with_route { |route, value| route << value**value }
    # => [[:a, :c, 4], [:b, 1]]
    #######
    def map_values_with_route(route = [], &block)
      values = []
      self.each { |key, value|
        route_copy = route.dup
        values.concat case value.class.to_s
          when 'Hash', 'NestedHash' then
            NestedHash[value].map_values_with_route(route_copy.concat([key]), &block)
          else [block_given? ? yield(route_copy.concat([key]), value) : route_copy.concat([key, value])]
        end
      }
      values
    end
  end

end
