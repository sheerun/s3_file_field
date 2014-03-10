S3FileField.config do |c|
  c.access_key_id = ENV['AWS_ACCESS_KEY_ID']
  c.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  c.bucket = ENV['AWS_BUCKET']
  # c.acl = "public-read"
  # c.expiration = 10.hours.from_now.utc.iso8601
  # c.max_file_size = 500.megabytes
  # c.conditions = []
  # c.key_starts_with = 'uploads/
end
