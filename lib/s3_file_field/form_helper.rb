module S3FileField
  class Error < StandardError; end

  module FormBuilder
    def s3_file_field(method, options = {})
      self.multipart = true
      @template.s3_file_field(@object_name, method, objectify_options(options))
    end
  end

  module FormHelper
    def self.included(arg)
      ActionView::Helpers::FormBuilder.send(:include, S3FileField::FormBuilder)
    end

    def s3_file_field(object_name, method, options = {})
      options = S3Uploader.new(options).field_options

      if ::Rails.version.to_i >= 4
        ActionView::Helpers::Tags::FileField.new(
          object_name, method, self, options
        ).render
      else
        ActionView::Helpers::InstanceTag.new(
          object_name, method, self, options.delete(:object)
        ).to_input_field_tag("file", options.update(:size => nil))
      end
    end
  end
end
