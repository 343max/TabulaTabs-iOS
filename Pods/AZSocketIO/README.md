AZSocketIO
==========
AZSocketIO is a socket.io client for iOS. It:

* Supports websockets and xhr-polling transports
* Is about alpha stage
* Is heavily reliant on blocks for it's API
* Has appledocs for all user facing classes
* Welcomes patches and issues

Dependencies
------------
AZSocketIO uses cocoapods, so you shouldn't have to think too much about dependencies, but here they are.

* [SocketRocket](https://github.com/square/SocketRocket)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)

AZSocketIO leverages AFNetworking's JSON encoding and decoding facilities, which means that you don't need anything else if you are iOS 5+. NSJSONSerialization doesn't exist on iOS 4, so you'll have to add a JSON parser there. Check [AFNetworking's docs](https://github.com/AFNetworking/AFNetworking#requirements) for more info.

Usage
-----
``` objective-c
AZSocketIO *socket = [[AZSocketIO alloc] initWithHost:@"localhost" andPort:@"9000"];
[socket setEventRecievedBlock:^(NSString *eventName, id data) {
    NSLog(@"%@ : %@", eventName, data);
}];
[socket connectWithSuccess:^{
	[socket emit:@"Send Me Data" args:@"cows" error:nil];
} andFailure:^(NSError *error) {
    NSLog(@"Boo: %@", error);
}];
```

Contact
-------
Pat Shields

* http://github.com/pashields
* http://twitter.com/whatidoissecret

License
-------
Apache 2.0