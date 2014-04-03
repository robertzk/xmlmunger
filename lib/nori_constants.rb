module XMLMunger

  class NoriConstants
    def self.default_options
      { strip_namespaces: true,
        convert_tags_to: lambda { |tag| tag.snakecase.to_sym } }
    end
  end

end
