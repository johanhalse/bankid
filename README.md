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
2. You get an authentication object containing -- among other things -- an `orderRef` and a `startSecret` back
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
raise "logged in!" if response.status == "complete"
```

Keep polling until your response status changes to "complete", and the response object will be a struct containing the `completion_data` property you're ultimately looking for.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bankid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
