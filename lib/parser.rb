module XMLMunger

  class Parser
    attr_accessor :xml

    def initialize xml, nori_options = {}
      unless xml.is_a?(Hash)
        unless xml.is_a?(String)
          raise ArgumentError.new("Argument xml should be a Hash or String (XML file).")
        end
        @xml = Nori.new(NoriConstants.default_options.merge(nori_options)).parse(xml)
      else
        @xml = xml
      end
    end

    def run options = {}
      raise TypeError.new("options argument must be a hash") unless options.is_a?(Hash)
      options = default_options.merge options

      xml = options[:filter].inject(xml) { |hash, key| hash[key] }
      array_of_arrays_of_data = NestedHash[@xml].map_values_with_route.map { |value|
        [options[:prefix] + value[0..value.length-2].map(&:to_s).join(options[:sep]), value[value.length-1]]
      }.select { |v| !(options[:prohibited_types].any? { |type| v[1].is_a?(type) }) } 
      Hash[array_of_arrays_of_data]
    end

    protected

    def default_options
      {
        prefix: '',
        filter: [],
        sep: '_',
        prohibited_types: [Array]
      }
    end

  end

end

