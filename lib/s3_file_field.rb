require 's3_file_field/version'
require 'jquery-fileupload-rails'

require 'base64'
require 'openssl'
require 'digest/sha1'

require 's3_file_field/config_aws'
require 's3_file_field/form_helper'
require 's3_file_field/railtie'
require 's3_file_field/engine'

ActionView::Base.send(:include, S3FileField::FormHelper)
