module S3FileField
  class S3Uploader  # :nodoc:
    attr_accessor :options

    def initialize(original_options = {})

      default_options = {
        access_key_id: S3FileField.config.access_key_id,
        secret_access_key: S3FileField.config.secret_access_key,
        bucket: S3FileField.config.bucket,
        acl: "public-read",
        expiration: 10.hours.from_now.utc.iso8601,
        max_file_size: 500.megabytes,
        conditions: [],
        key_starts_with: S3FileField.config.key_starts_with || 'uploads/',
        region: S3FileField.config.region || 's3',
        url: S3FileField.config.url,
        ssl: S3FileField.config.ssl
      }

      @key = original_options[:key]
      @original_options = original_options

      # Remove s3_file_field specific options from original options
      extracted_options = @original_options.extract!(*default_options.keys).
        reject { |k, v| v.nil? }

      @options = default_options.merge(extracted_options)

      unless @options[:access_key_id]
        raise Error.new("Please configure access_key_id option.")
      end

      unless @options[:secret_access_key]
        raise Error.new("Please configure secret_access_key option.")
      end

      if @options[:bucket].nil? && @options[:url].nil?
        raise Error.new("Please configure bucket name or url.")
      end
    end

    def field_options
      @original_options.merge(data: field_data_options)
    end

    def field_data_options
      {
        url: url,
        key: key,
        acl: @options[:acl],
        aws_access_key_id: @options[:access_key_id],
        policy: policy,
        signature: signature
      }.merge(@original_options[:data] || {})
    end

    private

    def key
      @key ||= "#{@options[:key_starts_with]}{timestamp}-{unique_id}-#{SecureRandom.hex}/${filename}"
    end

    def url
      @url ||=
        if @options[:url]
          @options[:url]
        else
          protocol = @options[:ssl] == true ? "https" : @options[:ssl] == false ? "http" : nil
          subdomain = "#{@options[:bucket]}.#{@options[:region]}"
          domain = "//#{subdomain}.amazonaws.com/"
          [protocol, domain].compact.join(":")
        end
    end

    def policy
      Base64.encode64(policy_data.to_json).gsub("\n", '')
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
          OpenSSL::Digest.new('sha1'),
          @options[:secret_access_key], policy
        )
      ).gsub("\n", '')
    end
  end
end
