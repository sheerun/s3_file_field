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
      uploader = S3Uploader.new(options)
      options = uploader.field_options.merge options
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

    class S3Uploader
      def initialize(options)
        @key_starts_with = options.delete(:key_starts_with) || 'uploads/'
        @access_key_id = options.delete(:aws_access_key_id) || S3FileField.config.access_key_id
        @secret_access_key = options.delete(:aws_secret_access_key) || S3FileField.config.secret_access_key
        @bucket = options.delete(:bucket) || S3FileField.config.bucket
        @acl = options.delete(:acl) || 'public-read'
        @expiration = options.delete(:expiration) || 10.hours.from_now.utc.iso8601
        @max_file_size = options.delete(:max_file_size) || 500.megabytes
        @key = options.delete(:key)
        @conditions = options.delete(:conditions) || []

        @field_data_options = {
          url: url,
          key: key,
          acl: @acl,
          aws_access_key_id: @access_key_id,
          policy: policy,
          signature: signature
        }.merge! options.delete(:data)


        unless @access_key_id
          raise Error.new("Please configure aws_access_key_id option.")
        end

        unless @secret_access_key
          raise Error.new("Please configure aws_secret_access_key option.")
        end

        unless @bucket
          raise Error.new("Please configure bucket name.")
        end
      end

      def field_options
        { data: @field_data_options }
      end

      def key
        @key ||= "#{@key_starts_with}{timestamp}-{unique_id}-#{SecureRandom.hex}/${filename}"
      end

      def url
        "//#{@bucket}.s3.amazonaws.com/"
      end

      def policy
        Base64.encode64(policy_data.to_json).gsub("\n", "")
      end

      def policy_data
        {
          expiration: @expiration,
          conditions: [
            ["starts-with", "$key", @key_starts_with],
            ["starts-with", "$x-requested-with", ""],
            ["content-length-range", 0, @max_file_size],
            ["starts-with","$Content-Type",""],
            {bucket: @bucket},
            {acl: @acl},
            {success_action_status: "201"}
          ] + @conditions
        }
      end

      def signature
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha1'),
            @secret_access_key, policy
          )
        ).gsub("\n", "")
      end
    end
  end
end
