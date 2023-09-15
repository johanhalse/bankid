# Bankid

Bankid authentication for Ruby!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bankid'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install bankid

## Usage

Bankid authentication is done in the following steps:

1. Generate an "authentication order" by hitting the `auth` endpoint
2. You get an authentication object containing, among other things, an `orderRef` and a `startSecret` back
3. Use the data contained in the authentication object to show the user a QR code
4. Poll the `collect` endpoint every now and then using the `orderRef` you got back in the second step
5. When user has scanned the QR code and logged in, the poll will return their data.

This is step 1:

```ruby
client = Bankid::Auth.new
auth = client.generate_authentication(ip: request.remote_ip) # user's ip address
```

Keep the values from that `auth` object around, you'll need them in later steps, as you'll see. Note that you should never reveal the `qr_start_secret` to users!

Onward to step 3, showing a QR code:

```ruby
@qr_code = client.generate_qr(
  start_token: auth.qr_start_token,
  start_secret: auth.qr_start_secret,
  seconds: seconds_elapsed_since_auth_response_received
)
```

Bankid uses animated QR, which means the code is a SHA256 hex digest that includes elapsed seconds. You'll need some way to keep track of those as you refresh the QR code and poll for a response.

Final step:

```ruby
response = client.poll(order_ref: auth.order_ref)
raise "logged in!" if response.state == "complete"
```

Keep polling until your response state changes to "complete", and the response object will be a struct containing the `completion_data` property you're ultimately looking for. State will be `pending` until then, or `failed` if user has aborted or something unexpected has happened.

Note that you'll only get `complete` and `completion_data` returned once! Make sure you act on the data when it's consumed—the next time you ask, you're going to get a failed response because the order has been marked as successful and deleted.

## Certificates

Your BankID provider will have given you a certificate. It might be in `.p12` format. If that's the case, you'll need to convert it to an OpenSSL X509 certificate - version 0.1.x of the BankID gem relied on PKCS12 which saw [big changes in OpenSSL v3](https://github.com/johanhalse/bankid/issues/3), so the implementation has been switched to X509 instead. The gem looks for a certificate and a key in these default locations:

```
./config/certs/#{environment}_client_certificate.pem
./config/certs/#{environment}_client_certificate.key
```

If you're upgrading from 0.1.x and want to convert an existing p12 key, it's pretty straightforward:

```
# Export certificate
openssl pkcs12 -legacy -in my_certificate.p12 -clcerts -nokeys -out my_certificate.pem
# Export key
openssl pkcs12 -legacy -in my_certificate.p12 -clcerts -nocerts -out my_certificate.key
```

That should hopefully get things running again.

This gem includes the issuer certificate as well: you'll find the development cert in `(gem path)/config/development_bankid_certificate.pem` and production `(gem path)/config/production_bankid_certificate.pem)`. These are loaded unless you've provided your own in your app's `config/certs` path. Also included are the development p12 and pem/key files from [this page](https://www.bankid.com/en/utvecklare/guider/teknisk-integrationsguide/miljoer) so you can run with demo certificates in test and production.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bankid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
