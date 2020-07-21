# No More SNS SDK


## What is this

lightweight wrapper of [OAuthSwift/OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)

I don't want to use their fat SDKs... and don't want to config URLSchemes... you too?


## Features

- supports iOS 11 ~
- Twitter Login
- Facebook Login without SDK, URLScheme
- Google Login without SDK, URLScheme


## How to use

See Example Appication.


## Carthage

https://github.com/Carthage/Carthage

Write your `Cartfile`

```
github "dnpp73/NoMoreSNSSDK"
```

and run

```sh
carthage bootstrap --cache-builds --no-use-binaries --platform iOS
```

or

```sh
carthage update --cache-builds --no-use-binaries --platform iOS
```


## License

[MIT](/LICENSE)
