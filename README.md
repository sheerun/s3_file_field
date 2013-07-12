# S3 File Field

Stand-alone file field for S3 Direct Upload working with Rails nested forms.

Works as an extension of [jQuery File Upload](http://blueimp.github.io/jQuery-File-Upload/) JavaScript plugin and supports IE 7-10.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 's3_direct_upload'
```

Then add a new initalizer with your AWS credentials:

**config/initalizers/s3_file_field.rb**
```ruby
S3FileField.config do |c|
  c.access_key_id = ENV['AWS_ACCESS_KEY_ID']
  c.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  c.bucket = ENV['AWS_BUCKET']
end
```

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

Add the following js to your asset pipeline:

**application.js.coffee**
```coffeescript
#= require s3_file_field
```

## Usage

Create a new view that uses the form helper `s3_uploader_form`:
```haml
= form.s3_file_field :movie, :class => 'js-s3_file_field'
.progress
  .meter{ :style => "width: 0%" }
```

Then in your application.js.coffee something like:
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

Notice that after upload you have to re-fetch file field from DOM by its ID. That's becase
jQuery File Upload clones it somewhere else and `$(this)` reference points to the original input.


## Advanced customization

You can use any options / API available for jQuery File Upload plugin.

After successful upload, you'll find file data in `data.result` field:

```json
{
  "filepath": "uploads/v3w3qzcb1d78pvi/something.gif",
  "url": "https://foobar.s3.amazonaws.com/uploads/v3w3qzcb1d78pvi/something.gif",
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
