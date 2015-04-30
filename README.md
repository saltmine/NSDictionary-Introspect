# NSDictionary-Introspect

**Objective-C Runtime Property Introspection**

To print out the properties and values of a class on demand in the form of a NSDictionary. For more information, read: https://medium.com/@keepsaltmine/objective-c-runtime-property-introspection-c96f7884acea

## Installation

[CocoaPods](http://cocoapods.org) is the recommended method of installing `NSDictionary-Introspect`. Simply add the following line to your `Podfile`:

#### Podfile

```ruby
pod 'NSDictionary-Introspect'
```

## Usage

To use this code, override the description method of your NSObject like so:

``` objective-c
- (NSString *)description {
    NSDictionary *dictionary = [NSDictionary dictionaryWithPropertiesOfObject:self];
    return [NSString stringWithFormat:@"%@", dictionary];
}
```

And then, simply call: 

``` objective-c
 [YourNSObjectInstance description];
```

## Requirements

- Xcode 6
- iOS 7+ Base SDK

## Contact

Chamara Paul

- chamara@keep.com
- http://twitter.com/chamwow

## License

`NSDictionary-Introspect` is available under the MIT license. See the LICENSE file for more info.



