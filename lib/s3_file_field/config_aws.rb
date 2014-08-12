require "singleton"

module S3FileField
  class Config
    include Singleton

    ATTRIBUTES = [
      :access_key_id, :secret_access_key, :bucket, :prefix_to_clean,
      :region, :url, :key_starts_with, :ssl]

    attr_accessor *ATTRIBUTES
  end

  def self.config
    if block_given?
      yield Config.instance
    end
    Config.instance
  end
end
