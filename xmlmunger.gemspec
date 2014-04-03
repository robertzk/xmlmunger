Gem::Specification.new do |s|
  s.name        = 'xmlmunger'
  s.version     = '0.0.1'
  s.date        = '2014-04-03'
  s.summary     = 'Convert XML files into flat hashes with automatic naming via nested paths'
  s.description = %(XML files typically come in nested structures. For data extraction purposes,
    we frequently wish to have a flat hash instead. The naming then becomes tricky, because
    there can be collision in the terminal nodes. However, if we use the chain of parent tags
    joined with an underscore, this provides a unique name for every data point in the XML file.
    The goal of this package is to make it very simple to convert XML files into flat hashes.
  ).sqush
  s.authors     = ["Robert Krzyzanowski"]
  s.email       = 'rkrzyzanowski@gmail.com'
  s.files       = ["lib/xmlmunger.rb"]
  s.homepage    = 'http://avantcredit.com'
  s.license       = 'MIT'
end

