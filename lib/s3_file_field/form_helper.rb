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
      ActionView::Helpers::Tags::FileField.new(
        object_name, method, self,
        options.reverse_merge(uploader.field_options)
      ).render
    end

    class S3Uploader
      def initialize(options)
        @options = options.reverse_merge(
          aws_access_key_id: S3FileField.config.access_key_id,
          aws_secret_access_key: S3FileField.config.secret_access_key,
          bucket: S3FileField.config.bucket,
          acl: "public-read",
          expiration: 10.hours.from_now.utc.iso8601,
          max_file_size: 500.megabytes,
          key_starts_with: options[:key_starts_with] || "uploads/"
        )

        unless @options[:aws_access_key_id]
          raise Error.new("Please configure aws_access_key_id option.")
        end

        unless @options[:aws_secret_access_key]
          raise Error.new("Please configure aws_secret_access_key option.")
        end

        unless @options[:bucket]
          raise Error.new("Please configure bucket name.")
        end
      end

      def field_options
        {
          data: {
            :url => url,
            :key => @options[:key] || key,
            :acl => @options[:acl],
            :'aws-access-key-id' => @options[:aws_access_key_id],
            :policy => policy,
            :signature => signature
          }.reverse_merge(@options[:data] || {})
        }
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
          ] + (@options[:conditions] || [])
        }
      end

      def signature
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::Digest.new('sha1'),
            @options[:aws_secret_access_key], policy
          )
        ).gsub("\n", "")
      end
    end
  end
end
