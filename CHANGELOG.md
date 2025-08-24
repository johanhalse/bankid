## [3.1.0] - 2024-02-06

Update the API version to 6.0. Thank you to [Martin Westin](https://github.com/eimermusic)

## [3.0.0] - 2024-02-06

Major backwards-incompatible overhaul, moving the gem closer to the Rails ecosystem and making things a lot easier. New documentation is in the [wiki](https://github.com/johanhalse/bankid/wiki).

- Add signatures
- Add `Rails.config` configuration instead of passing environment to the client
- Automatically store secrets in `Rails.cache`
- Add railtie and dummy test app using `vcr`
- Split Result and Secret into different objects and return both from `collect`
- Handle translated `hintCode` messages to users via Rails I18n
- Function for autostart link
- More turnkey handling of development certificates
- Some more understandable errors raised (missing certificates & environment)
- ...etc

## [2.0.1] - 2023-09-21

- Automatically pick up certificates from gem unless present in project

## [2.0.0] - 2023-09-15

- Refresh development client certificate
- Replace `Poll` API with a more useful `Result` struct containing a `state` method

## [1.0.1] - 2022-12-11

- Include new development client certificate instead of the old expired one

## [1.0.0] - 2022-09-30

- Deprecate the `PKCS12` algorithm in favor of `X509`: [issue #3](https://github.com/johanhalse/bankid/issues/3)

## [0.1.2] - 2022-09-08

- Add `pending?` method call for poll response object

## [0.1.1] - 2022-04-06

- Make Poll object accept error codes and details from [errors](https://www.bankid.com/utvecklare/guider/teknisk-integrationsguide/graenssnittsbeskrivning/felfall)

## [0.1.0] - 2021-10-25

- Initial release
