$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |gem|
  gem.name = 'hri-test-helpers'
  gem.version = '1.0.0'
  gem.date = '2021-09-01'
  gem.licenses = ['Apache-2.0']
  gem.summary = 'A collection of helper classes for the Health Record Ingestion Service, the Alvearie deployment-ready component for streaming data into the cloud'
  gem.description = 'A collection of helper classes that enable the HRI Management API to interface with IAM, Elastic, Flink, LogDNA, IBM AppId, IBM Cloud Object Storage, and IBM EventStreams'
  gem.authors = ['Fred Ricci']
  gem.email = 'fjricci@us.ibm.com'
  gem.homepage = 'https://github.com/Alvearie/hri-test-helpers'
  gem.files = Dir['lib/**/*.rb'] + %w(hri-test-helpers.gemspec README.md)
  gem.require_paths = ["lib"]
end