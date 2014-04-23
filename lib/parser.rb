require 'nori'

module XMLMunger

  class Parser
    attr_accessor :xml

    def initialize xml, nori_options = {}
      unless xml.is_a?(Hash)
        unless xml.is_a?(String)
          raise ArgumentError.new("Argument xml should be a Hash or String (XML file).")
        end
        @xml = ::Nori.new(NoriConstants.default_options.merge(nori_options)).parse(xml)
      else
        @xml = xml
      end
    end

    def run options = {}
      raise TypeError.new("options argument must be a hash") unless options.is_a?(Hash)
      options = default_options.merge options

      @xml = options[:filter].inject(xml) { |hash, key| hash[key] }
      array_of_arrays_of_data = NestedHash[xml].map_values_with_route do |route, value|
        next if route.any? { |r| r =~ /@/ } && !options[:attributes] # skip attributes
        route.map! { |s| s.to_s.tr(options[:strip_chars], '') }
        route = route.join(options[:sep])
        key = options[:prefix] + route
        # TODO: Should we parse out attributes from nested tags?

        [key, value]
      end.compact.reject { |k, v| options[:prohibited_types].any? { |type| v.is_a?(type) } } 
      Hash[array_of_arrays_of_data]
    end

    protected

    def default_options
      {
        prefix: '',
        filter: [],
        sep: '_',
        strip_chars: '',  # Whether to strip any characters from route names
        attributes: true, # Whether or not to parse XML tag attributes
        prohibited_types: [Array]
      }
    end

  end

end

