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
      parsed = decompose_hash(options)
      NestedHash[parsed]
    end

    def decompose_hash options = {}
      # prepare the options hash
      raise TypeError.new("options argument must be a hash") unless options.is_a?(Hash)
      options = default_options.merge options

      # move to the starting point and traverse the xml
      filtered = options[:filter].inject(xml) { |hash, key| hash[key] }
      traverse = NestedHash[filtered].map_values_with_route do |route, value|
        # skip attributes?
        next if !options[:attributes] && route.any? { |r| r =~ /@/ }
        # prohibited type?
        next if options[:prohibited_types].any? { |type| value.is_a?(type) }
        # extract data from lists
        value = ListHeuristics.new(value,options).to_variable_hash if value.is_a?(Array)
        [route, value]
      end.compact

      # create variable:value mapping
      # need the second iteration in case of list data
      parsed = NestedHash[traverse].map_values_with_route do |route, value|
        key = make_key(route, options)
        [key, value]
      end
      parsed
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

    private

    def make_key(route, options)
      route.
        flatten.
        map { |s| s.to_s.tr(options[:strip_chars], '') }.
        reject { |s| s.empty? }.
        join(options[:sep]).
        prepend(options[:prefix])
    end

  end

end

