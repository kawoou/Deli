![Deli](https://github.com/kawoou/Deli/raw/screenshot/deli.png)

<p align="center">
<a href="#"><img src="https://img.shields.io/badge/Swift-4.1.2-orange.svg" alt="Swift"/></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
<a href="http://cocoadocs.org/docsets/Deli"><img src="https://img.shields.io/cocoapods/v/Deli.svg?style=flat" alt="Version"/></a>
<a href="https://github.com/kawoou/Deli/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Deli.svg?style=flat" alt="License"/></a>
<a href="https://travis-ci.org/kawoou/Deli"><img src="https://travis-ci.org/kawoou/Deli.svg?branch=master" alt="CI Status"/></a>
<a href="http://kawoou.kr/Deli"><img src="http://kawoou.kr/Deli/badge.svg" alt="Jazzy"/></a>
<a href="http://cocoadocs.org/docsets/Deli"><img src="https://img.shields.io/cocoapods/p/Deli.svg?style=flat" alt="Platform"/></a>
</p>

Deli is an easy-to-use Dependency Injection Container that creates DI containers with all required registrations and corresponding factories.




## Table of Contents
* [Overview](#overview)
* [Getting Started](#getting-started)
  - [Build Phases](#build-phases)
* [Features](#features)
  - [Component](#1-component)
  - [Autowired](#2-autowired)
  - [LazyAutowired](#3-lazyautowired)
  - [Configuration](#4-configuration)
  - [Inject](#5-inject)
  - [Factory](#6-factory)
  - [Testable](#7-testable)
* [Installation](#installation)
  - [Cocoapods](#cocoapods)
  - [Carthage](#carthage)
  - [Command Line](#command-line)
* [Contributing](#contributing)
* [Requirements](#requirements)
* [Attributions](#attributions)
* [License](#license)



## Overview

Wanna spaghetti? or not.
As your project grows, will experience a complex. We can write the wrong code by mistake.

In [Spring framework](https://github.com/spring-projects/spring-framework) provides automatic registration using some code rules and throws the wrong Dependency Graph before running. I wanted these features to be in Swift.




## Getting Started

Simple setup for the automated configuration files, `deli.yml`.

If the configuration file does not exist, find the build target for a unique project in the current folders automatically. It works the same even if no `scheme` or `output` field is specified.

```yaml
target:
  - MyProject

config:
  MyProject:
    project: MyProject
    scheme: MyScheme
    include:
      - Include files...
    exclude:
      - Exclude files...
    className: DeilFactory
    output: Sources/DeliFactory.swift
```

You’ll have to make your targets `Shared`. To do this `Manage Schemes` and check the `Shared` areas:

![shared-build-scheme](https://github.com/kawoou/Deli/raw/screenshot/shared-build-scheme.png)

Then build with the provided binaries.

```bash
$ deli build
```

Dependency Graph is configured through source code analysis. It is saved as the file you specified earlier.

File contents as below:

```swift
//
//  Deli Factory
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    func load(context: AppContextType) {
        ...
    }

    required init() {}
}
```

Add the generated file to the project and call it from the app's launch point.

![drag-and-drop](https://github.com/kawoou/Deli/raw/screenshot/drag-and-drop-deli-factory.png)

AppDelegate.swift:

```swift
import UIKit
import Deli

class AppDelegate {
    
    var window: UIWindow?

    let context = AppContext.load([
        DeliFactory.self
    ])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
```



### Build Phases

Integrate Deli into an Xcode scheme to get warnings and errors displayed in the IDE.
Just add a new "Run Script Phase" with:

```bash
if which deli >/dev/null; then
  deli build
else
  echo "error: Deli not installed, download from https://github.com/kawoou/Deli"
fi
```

![Build Phase](https://github.com/kawoou/Deli/raw/screenshot/xcode-run-script.png)

Alternatively, if you've installed Deli via CocoaPods the script should look like this:

```bash
"${PODS_ROOT}/DeliBinary/deli" build
```



## Features
### 1. Component
The class, struct, and protocol can extend the `Component` protocol and will be registered automatically in the DI container.

`Component` can be used as below:

```swift
protocol UserService {
    func login(id: String, password: String) -> User?
    func logout()
}

class UserServiceImpl: UserService, Component {
    func login(id: String, password: String) -> User? {
        ...
    }
    func logout() {
        ...
    }

    init() {}
}
```

If the above code is written, you can use the `UserService` or `UserServiceImpl` type to load the dependency instance.



### 2. Autowired

The `Autowired` protocol is registered automatically, same as `Component` protocol. A difference, you can load the required dependencies from DI container.

`Autowired` can be used as below:

```swift
class LoginViewModel: Autowired {
    let userService: UserService

    required init(_ userService: UserService) {
        self.userService = userService 
    }
}
```

Easy right? So let's look at the code below.

```swift
protocol Book {
    var name: String { get }
    var author: String { get }
    var category: String { get }
}
struct Novel: Book {
    var qualifier: String {
        return "Novel"
    }

    var name: String {
        return ""
    }
    var author: String {
        return ""
    }
    var category: String {
        return "Novel"
    }
}
struct HarryPotter: Novel, Component {
    var name: String {
        return "Harry Potter"
    }
    var author: String {
        return "J. K. Rowling"
    }
}
struct TroisiemeHumanite: Novel, Component {
    var name: String {
        return "Troisième humanité"
    }
    var author: String {
        return "Bernard Werber"
    }
}
```

This code arranged the books through inheritance. You can get all of `Book` instances like below:

```swift
class LibraryService: Autowired {
    let books: [Book]

    required init(_ books: [Book]) {
        self.books = books
    }
}
```

Furthermore, What should do to get the books with the "Novel" qualifier?
In Deli, can be constructor injection in the below:

```swift
class LibraryService: Autowired {
    let bookcs: [Book]

    required init(Novel books: [Book]) {
        self.books = books
    }
}
```



### 3. LazyAutowired

If we can remove whole Circular Dependency cases, the world will be better than before, but it cannot be ruled completely.
A simple way to solve this problem is to initialize one of the dependency lazily.

Let's try `LazyAutowired` protocol:

```swift
class UserService: Autowired {
    let messageService: MessageService

    required init(_ messageService: MessageService) {
        self.messageService = messageService
    }
}
class FriendService: Autowired {
    let userService: UserService

    required init(_ userService: UserService) {
        self.userService = userService
    }
}
class MessageService: Autowired {
    let friendService: FriendService

    required init(_ friendService: FriendService) {
        self.friendService = friendService
    }
}
```

If you try to inject a MessageService, Circular Dependency will occurred.

```bash
$ deli validate

Error: The circular dependency exists. (MessageService -> FriendService -> UserService -> MessageService)
```

What if UserService extends `LazyAutowired`?

```swift
class UserService: LazyAutowired {
    let messageService: MessageService!

    func inject(_ messageService: MessageService) {
        self.messageService = messageService
    }

    required init() {}
}
```

The cycle was broken and the issue was resolved!
After MessageService instance successfully created, dependencies can be injected via `inject()` that UserService needed.

In addition, LazyAutowired can be specified qualifier like Autowired.
Below code injects a UserService instance with the "facebook" qualifier specified:

```swift
class FacebookViewModel: LazyAutowired {
    let userService: UserService!

    func inject(facebook userService: UserService) {
        self.userService = userService
    }

    required init() {}
}
```


### 4. Configuration

The `Configuration` protocol makes the user can register `Resolver` directly.

Let's look at the code:

```swift
class UserConfiguration: Configuration {
    let networkManager = Config(NetworkManager.self, ConfigurationManager.self) { configurationManager in
        let privateKey = "1234QwEr!@#$"
        return configurationManager.make(privateKey: privateKey)
    }

    init() {}
}
```
You can see privateKey is passed to ConfigurationManager on NetworkManager creation.

This NetworkManager instance is registered in DI container, and it will be managed as singleton.
(However, instance behavior can be changed by updating scope argument.)



### 5. Inject

As written, `Autowired` is registered in DI container. But you may want to use without registration. That's an `Inject`.

```swift
class LoginView: Inject {
    let viewModel = Inject(LoginViewModel.self)

    init() {}
}

class NovelBookView: Inject {
    let novels: [Book]!

    init() {
        self.novels = Inject([Book].self, qualifier: "Novel")
    }
}
```



### 6. Factory

In the front-end, often dynamically generating a model using the user's data. Let's take an example.

You must implement a friend list. When you select a cell from friends list, you need to present modal view of friend's information.
In this case, The friend data must be passed in the `Info Modal`.

This happens very often, `Factory` will help them.

Let's try `AutowiredFactory` protocol:

```swift
class FriendPayload: Payload {
    let userID: String
    let cachedName: String
    
    required init(with argument: (userID: String, cachedName: String)) {
        userID = argument.userID
        cachedName = argument.cachedName
    }
}

class FriendInfoViewModel: AutowiredFactory {
    let accountService: AccountService
    
    let userID: String
    var name: String
    
    required init(_ accountService: AccountService, payload: FriendPayload) {
        self.accountService = accountService
        self.userID = payload.userID
        self.name = payload.cachedName
    }
}
```

To pass a user-argument, you must implement a `Payload` protocol.
(Naturally, factories work by prototype scope)

Implemented `FriendInfoViewModel` can be used as below:

```swift
class FriendListViewModel: Autowired {
    let friendService: FriendService
    
    func generateInfo(by id: String) -> FriendInfoViewModel? {
        guard let friend = friendService.getFriend(by: id) else { return nil }
        
        return Inject(
            FriendInfoViewModel.self,
            with: (
                userID: friend.id,
                cachedName: friend.name
            )
        )
    }
    
    required init(_ friendService: FriendService) {
        self.friendService = friendService
    }
}
```

Next `LazyAutowiredFactory` protocol:

```swift
class FriendInfoViewModel: LazyAutowiredFactory {
    var accountService: AccountService!
    
    func inject(facebook accountService: AccountService) {
        self.accountService = accountService
    }
    
    required init(payload: TestPayload) {
        ...
    }
}
```

The difference between an AutowiredFactory and a LazyAutowiredFactory is that it is lazy injected with the relationship between Autowired and LazyAutowired.
However, payload injects by the constructor because passed by the user.



### 7. Testable

Deli provides methods for testing in AppContext.

It is `setTestMode()`:

```swift
public func setTestMode(_ active: Bool, qualifierPrefix: String)
```

Suppose that a test mode is activating using the method above. Then using the `qualifier` prefix when gets instances from DI containers(if it exists).

If you register a Mock object for testing in the DI Container, it will be gets first.

```swift
/// Register
AppContext.shared.register(
    AccountService.self,
    resolver: {
        let networkManager = AppContext.shared.get(NetworkManager.self, qualifier: "")!
        let libraryService = AppContext.shared.get(LibraryService.self, qualifier: "")!

        return MockAccountService(networkManager, libraryService)
    },
    qualifier: "test",
    scope: .singleton
)

/// Test Mode
AppContext.shared.setTestMode(true, qualifierPrefix: "test")

/// Inject
let accountService = Inject(AccountService.self)

if accountService is MockAccountService {
  print("Test Mode")
} else {
  print("Normal Mode")
}

/// Result
> Test Mode
```

An example of a test code is `Deli.xcodeproj`.



## Installation

### [Cocoapods](https://cocoapods.org/):

Simply add the following line to your Podfile:

```ruby
pod 'Deli'
```



### [Carthage](https://github.com/Carthage/Carthage):

```
github "kawoou/Deli"
```



### Command Line

```
$ deli help
Available commands:

   build      Build the Dependency Graph.
   generate   Generate the Dependency Graph.
   help       Display general or command-specific help
   upgrade    Upgrade outdated.
   validate   Validate the Dependency Graph.
   version    Display the current version of Deli
```



## Contributing

Any discussions and pull requests are welcomed.

If you want to contribute, [submit a pull request](https://github.com/kawoou/Deli/compare).



## Requirements

* Swift 3.1+



## Attributions

This project is powered by

 * [SourceKitten](https://github.com/jpsim/SourceKitten)
   - MIT License
   - Created by [JP Simard](https://github.com/jpsim)
 * [Yams](https://github.com/jpsim/Yams)
   - MIT License
   - Created by [JP Simard](https://github.com/jpsim)
 * [Regex](https://github.com/crossroadlabs/Regex)
   - Apache License 2.0
   - Created by [Crossroad Labs](https://github.com/crossroadlabs)
 * [Xcproj](https://github.com/xcodeswift/xcproj)
   - MIT License
   - Created by [xcode.swift](https://github.com/xcodeswift)
 * [Commandant](https://github.com/Carthage/Commandant)
   - MIT License
   - Created by [Carthage](https://github.com/Carthage)



## License

Deli is under MIT license. See the [LICENSE](https://github.com/kawoou/Deli/blob/master/LICENSE) file for more info.

