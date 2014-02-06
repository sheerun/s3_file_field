#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

jQuery.fn.S3FileField = (options) ->

  options = {} unless options?

  # support multiple elements
  if @length > 1
    @each -> $(this).S3Uploader options if @length > 1
    return this

  $this = this

  extractOption = (key) ->
    extracted = options[key]
    delete options[key]
    extracted

  getFormData = (data, form) ->
    formData = undefined
    return data(form) if typeof data is "function"
    return data if $.isArray(data)
    if $.type(data) is "object"
      formData = []
      $.each data, (name, value) ->
        formData.push
          name: name
          value: value
      return formData
    return []

  url = extractOption('url')
  add = extractOption('add')
  done = extractOption('done')
  fail = extractOption('fail')
  extraFormData = extractOption('formData')

  delete options['paramName']
  delete options['singleFileUploads']

  finalFormData = {}

  settings =
    # File input name must be "file"
    paramName: 'file'

    # S3 doesn't support multiple file uploads
    singleFileUploads: true

    # We don't want to send it to default form url
    url: url || $this.data('url')

    # For IE <= 9 force iframe transport
    forceIframeTransport: do ->
      userAgent = navigator.userAgent.toLowerCase()
      msie = /msie/.test( userAgent ) && !/opera/.test( userAgent )
      msie_version = parseInt((userAgent.match( /.+(?:rv|it|ra|ie)[\/: ]([\d.]+)/ ) || [])[1], 10)
      msie && msie_version <= 9

    add: (e, data) ->
      data.files[0].unique_id = Math.random().toString(36).substr(2,16)
      if add? then add(e, data) else data.submit()

    done: (e, data) ->
      data.result = build_content_object data.files[0], data.result
      done(e, data) if done?

    fail: (e, data) ->
      fail(e, data) if fail?

    formData: (form) ->
      unique_id = @files[0].unique_id
      finalFormData[unique_id] =
        key: $this.data('key').replace('{timestamp}', new Date().getTime()).replace('{unique_id}', unique_id)
        'Content-Type': @files[0].type
        acl: $this.data('acl')
        'AWSAccessKeyId': $this.data('aws-access-key-id')
        policy: $this.data('policy')
        signature: $this.data('signature')
        success_action_status: "201"
        'X-Requested-With': 'xhr'

      getFormData(finalFormData[unique_id]).concat(getFormData(extraFormData))

  jQuery.extend settings, options

  build_content_object = (file, result) ->
    domain = settings.url.replace(/\/+$/, '').replace(/^(https?:)?/, 'https:')
    content = {}
    if result # Use the S3 response to set the URL to avoid character encodings bugs
      content.url            = $(result).find("Location").text()
      content.filepath       = $('<a />').attr('href', content.url)[0].pathname
    else # IE <= 9 retu      rn a null result object so we use the file object instead
      content.filepath   = finalFormData[file.unique_id]['key'].replace('/${filename}', '')
      content.url        = domain + '/' + content.filepath + '/' + encodeURIComponent(file.name)
    content.filename   = file.name
    content.filesize   = file.size if 'size' of file
    content.filetype   = file.type if 'type' of file
    content.unique_id  = file.unique_id if 'unique_id' of file
    content

  $this.fileupload settings
