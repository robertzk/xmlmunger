require 'xmlmunger/version'
require 'nori_constants'
require 'nested_hash'
require 'list_heuristics'
require 'parser'

module XMLMunger

  # Add native support to testing libraries

  module Test
    module Unit
      class TestCase
        include ::XMLMunger
      end
    end
  end

  module MiniTest
    class Unit
      class TestCase
        include ::XMLMunger
      end
    end
  end


  module RSpec
    module Core
      class ExampleGroup
        include ::XMLMunger
      end
    end
  end

end
