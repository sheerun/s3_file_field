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
      def initialize(input_options)
        @options = {
          access_key_id: S3FileField.config.access_key_id,
          secret_access_key: S3FileField.config.secret_access_key,
          bucket: S3FileField.config.bucket,
          acl: 'public-read',
          expiration: 10.hours.from_now.utc.iso8601,
          max_file_size: 500.megabytes,
          conditions: [],
          key_starts_with: 'uploads/',
        }

        @options.merge!(input_options.extract! *@options.keys)

        @key = input_options.delete(:key)

        @field_data_options = {
          url: url,
          key: key,
          acl: @options[:acl],
          aws_access_key_id: @options[:access_key_id],
          policy: policy,
          signature: signature
        }.merge! input_options.delete(:data)


        unless @options[:access_key_id]
          raise Error.new("Please configure aws_access_key_id option.")
        end

        unless @options[:secret_access_key]
          raise Error.new("Please configure aws_secret_access_key option.")
        end

        unless @options[:bucket]
          raise Error.new("Please configure bucket name.")
        end
      end

      def field_options
        { data: @field_data_options }
      end

      def key
        @key ||= "#{@options[:key_starts_with]}{timestamp}-{unique_id}-#{SecureRandom.hex}/${filename}"
      end

      def url
        "//#{@options[:bucket]}.s3.amazonaws.com/"
      end

      def policy
        Base64.encode64(policy_data.to_json).gsub("\n", "")
      end

      def policy_data
        {
          expiration: @options[:expiration],
          conditions: [
            ["starts-with", "$key", @options[:key_starts_with]],
            ["starts-with", "$x-requested-with", ""],
            ["content-length-range", 0, @options[:max_file_size]],
            ["starts-with","$Content-Type",""],
            {bucket: @options[:bucket]},
            {acl: @options[:acl]},
            {success_action_status: "201"}
          ] + @options[:conditions]
        }
      end

      def signature
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha1'),
            @options[:secret_access_key], policy
          )
        ).gsub("\n", "")
      end
    end
  end
end
