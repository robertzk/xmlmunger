require 'xmlmunger/version'
require 'xmlmunger/nori_constants'
require 'xmlmunger/nested_hash'
require 'xmlmunger/list_heuristics'
require 'xmlmunger/parser'

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
