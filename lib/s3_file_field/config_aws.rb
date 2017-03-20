require "singleton"

module S3FileField
  class Config
    include Singleton

    ATTRIBUTES = [
      :access_key_id,
      :secret_access_key,
      :bucket,
      :acl,
      :expiration,
      :max_file_size,
      :conditions,
      :prefix_to_clean,
      :region,
      :key_starts_with,
      :ssl,
      :url
    ]

    attr_accessor *ATTRIBUTES
  end

  def self.config
    if block_given?
      yield Config.instance
    end

    Config.instance
  end
end
