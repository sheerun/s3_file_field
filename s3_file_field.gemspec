# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3_file_field/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Adam Stankiewicz"]
  gem.email         = ["sheerun@sher.pl"]
  gem.description   = %q{Form helper for Direct Uploading to Amazon S3 using CORS and jquery-file-upload}
  gem.summary       = %q{Form helper for Direct Uploading to Amazon S3 using CORS and jquery-file-upload}
  gem.homepage      = ""

  gem.files         = Dir["{lib,app}/**/*"] + ["LICENSE", "README.md"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "s3_file_field"
  gem.require_paths = ["lib"]
  gem.version       = S3FileField::VERSION

  gem.add_dependency 'rails', '>= 3.2'
  gem.add_dependency 'coffee-rails', '>= 3.2.1'
  gem.add_dependency 'sass-rails', '>= 3.2.5'
  gem.add_dependency 'jquery-fileupload-rails', '~> 0.4.1'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
end
