# DEPRECATED

S3 File Field is no longer used or maintained by Jolly Good Code. Please use [attache][attache] instead.

Thanks!

[attache]: https://github.com/choonkeat/attache

# S3 File Field [![Build Status][travis-img-url]][travis-url]

[travis-img-url]: https://travis-ci.org/sheerun/s3_file_field.png
[travis-url]: https://travis-ci.org/sheerun/s3_file_field

jQuery File Upload extension for direct uploading to Amazon S3 using CORS

Works as an extension of [jQuery File Upload](http://blueimp.github.io/jQuery-File-Upload/) JavaScript plugin and supports IE 7-10.

It supports multiple upload, and per-input configuration.

## Installation

**Gemfile**
```ruby
gem 's3_file_field'
```

**application.coffee**
```coffeescript
#= require s3_file_field
```

**config/initializers/s3_file_field.rb**
```ruby
S3FileField.config do |c|
  c.access_key_id = ENV['AWS_ACCESS_KEY_ID']
  c.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  c.bucket = ENV['AWS_BUCKET']
  # c.acl = "public-read"
  # c.expiration = 10.hours.from_now.utc.iso8601
  # c.max_file_size = 500.megabytes
  # c.conditions = []
  # c.key_starts_with = 'uploads/
  # c.ssl = true # if true, force SSL connection
end
```

### S3 configuration

Make sure your AWS S3 CORS Settings for your bucket look like this:
```xml
<CORSConfiguration>
  <CORSRule>
    <AllowedOrigin>*</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedMethod>POST</AllowedMethod>
    <AllowedMethod>PUT</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
  </CORSRule>
</CORSConfiguration>
```

In production the AllowedOrigin key should be your base url like `http://example.com`

Also ensure you've added `PutObject` and `PutObjectAcl` permission in your bucket policy. Here is mine:
```json
{
  "Version": "2008-10-17",
  "Id": "Policy1372930880859",
  "Statement": [
    {
      "Sid": "Stmt1372930877007",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::BUCKET_NAME/*"
    }
  ]
}
```

## Basic usage

```haml
= form_for :user do |f|
  = f.s3_file_field :avatar, :class => 'js-s3_file_field'
  .progress
    .meter{ :style => "width: 0%" }
```

```coffeescript
jQuery.ready ->
  $('.js-s3_file_field').S3FileField
    done: (e, data) -> console.log(data.result.url)
```

## Advanced usage

```haml
= form_for :user do |f|
  = f.s3_file_field :avatar,
    :class => 'js-s3_file_field',
    :key => "/uploads/${timestamp}/${filename}"
  .progress
    .meter{ :style => "width: 0%" }
```

```coffeescript
ready = ->
  $(".js-s3_file_field").each ->
    id = $(this).attr('id')
    $this = -> $("##{id}")
    $progress = $(this).siblings('.progress').hide()
    $meter = $progress.find('.meter')
    $(this).S3FileField
      add: (e, data) ->
        $progress.show()
        data.submit()
      done: (e, data) ->
        $progress.hide()
        $this().attr(type: 'text', value: data.result.url, readonly: true)
      fail: (e, data) ->
        alert(data.failReason)
      progress: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        $meter.css(width: "#{progress}%")

$(document).ready(ready)
$(document).on('page:load', ready)
```

## Advanced customization

You can use any options / API available for jQuery File Upload plugin.

For full list of options reference [jQuery File Field wiki page](https://github.com/blueimp/jQuery-File-Upload/wiki/Options)

After successful upload, you'll find file data in `data.result` field:

```json
{
  "url": "https://foobar.s3.amazonaws.com/uploads/v3w3qzcb1d78pvi/something.gif",
  "filepath": "uploads/v3w3qzcb1d78pvi/something.gif",
  "filename": "something.gif",
  "filesize": 184387,
  "filetype": "image\/gif",
  "unique_id": "v3w3qzcb1d78pvi"
}
```

## Cleaning old uploads on S3

[Check out this article on Lifecycle Configuration](http://docs.aws.amazon.com/AmazonS3/latest/UG/LifecycleConfiguration.html).

## Thanks

* [s3_direct_upload](https://github.com/waynehoover/s3_direct_upload)
* [gallery-jquery-fileupload](https://github.com/railscasts/383-uploading-to-amazon-s3/tree/master/gallery-jquery-fileupload)

## License

This repository is MIT-licensed. You are awesome.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/sheerun/s3_file_field/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
