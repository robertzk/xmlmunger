require 'xmlmunger/version'
require 'nori_constants'
require 'nested_hash'
require 'parser'

module XMLMunger

  # Add native support to testing libraries

  module Test # :nodoc:
    module Unit # :nodoc:
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
       # Time warp to the specified time for the duration of the passed block.
      end
    end
  end

end
