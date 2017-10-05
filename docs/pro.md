# Artillery Pro Documentation

<i class="fa fa-info-circle" aria-hidden="true"></i> This page documents [Artillery Pro](/pro/), a commercial extension to the open-source Artillery. For information on licensing &amp; pricing of Artillery Pro, refer to [https://artillery.io/pro/](https://artillery.io/pro).

## Setting up Artillery Pro

### Install

Install Artillery Pro with:

```bash
npm install -g artillery-pro
```

<i class="fa fa-info-circle" aria-hidden="true"></i> You need to have Artillery installed first. If you don't have it installed already, run `npm install -g artillery`

<i class="fa fa-exclamation-circle" aria-hidden="true"></i> **NOTE**: Artillery Pro should work with Node.js `v4+` but Node.js `v6.x` (the LTS release) is the recommended and officially supported version.

### Activate

Artillery Pro needs to be activated before use:

```bash
artillery activate-pro
```

Once the activation process is complete, Artillery Pro features may be used.

<i class="fa fa-info-circle" aria-hidden="true"></i> Currently, a Github account is required to complete the activation process.

## File uploads

To submit forms containing one or more file fields use the `formData` attribute on the request and`fromFile` to specify the file to be uploaded.

The file upload must also be enabled in the `config` section of your script.

```yaml
config:
  target: "http://example.com"
  #
  # Enable the file upload plugin:
  #
  plugins:
    http-file-uploads: {}
scenarios:
  - flow:
      #
      # Upload a file through a form with two fields:
      # 1. name (text)
      # 2. avatar (file data from ./files/avatar.jpg, relative to the location
      #    of the test script)
      #
      post:
        url: "/upload"
        formData:
          name: "Bart Simpson"
          avatar:
            fromFile: "./files/avatar.jpg"
```

Variables may be used with `fromFile` to randomize the files being uploaded. For example:

```yaml
config:
  target: "http://example.com"
  #
  # Enable the file upload plugin:
  #
  plugins:
    http-file-uploads: {}
  variables:
    filename:
      - "avatar1.jpg"
      - "avatar2.jpg"
      - "avatar3.jpg"
      - "avatar4.jpg"
scenarios:
  - flow:
      #
      # Upload a file through a form with two fields:
      # 1. name (text)
      # 2. avatar (file data from ./files/avatar.jpg, relative to the location
      #    of the test script)
      #
      post:
        url: "/upload"
        formData:
          name: "Bart Simpson"
          avatar:
            fromFile: "./files/{{ filename }}"
```

### Uploading multiple files

To upload more than one file, use multiple `fromFile` attributes:

```yaml
- post:
    url: "/upload"
    formData:
      name: "Homer Simpson"
      resume:
        fromFile: "./files/resume.pdf"
      cover_letter:
        fromFile: "./files/cover_letter.pdf"
```

### Customizing file metadata

File metadata may be customized:

```yaml
- post:
    url: "/upload"
    formData:
      name: "Homer Simpson"
      resume:
        value:
          fromFile: "./files/resume.pdf"
        options:
          # original filename seen by the server
          filename: "homer_simpson_resume.pdf"
          conentType: "application/pdf"
```

### Errors

If a file cannot be read, an `ENOENT` error will be reported in Artillery's output.

## SSL client authentication

To configure SSL client authentication provide the key and the certificate to be used in TLS settings and enable the SSL client auth plugin in `config`:

```yaml
config:
  target: "https://example.com"
  tls:
    # useful for testing, should not be used in production:
    rejectUnauthorized: false
    #
    # Specify client key and certificate:
    #
    client:
      key: "./client-key.pem"
      cert: "./client-crt.pem"
  #
  # Enable the plugin:
  #
  plugins:
    http-ssl-auth: {}
```

Once configured, all requests will use the provided key and certificate for authentication.

You can provide a password for the key with the `passphrase` option:

```
config:
  target: "https://example.com"
  tls:
    # useful for testing, should not be used in production:
    rejectUnauthorized: false
    #
    # Specify client key and certificate:
    #
    client:
      key: "./client-key.pem"
      cert: "./client-crt.pem"
      passphrase: "mysecretpassword"
  #
  # Enable the plugin:
  #
  plugins:
    http-ssl-auth: {}
```

To specify that a request should **not** use SSL client auth, set `sslAuth` to `false`:

```yaml
  - flow:
      - get:
          url: "https://example.com/some/url"
          sslAuth: false # ignore SSL client auth settings
```

<!--
## NTLM Authentication
## `ensure`
-->
