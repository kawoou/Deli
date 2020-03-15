![Deli](https://github.com/kawoou/Deli/raw/screenshot/deli.png)

<p align="center">
<a href="#"><img src="https://img.shields.io/badge/Swift-4.2-orange.svg" alt="Swift"/></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
<a href="http://cocoadocs.org/docsets/Deli"><img src="https://img.shields.io/cocoapods/v/Deli.svg?style=flat" alt="Version"/></a>
<a href="https://github.com/kawoou/Deli/blob/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/Deli.svg?style=flat" alt="License"/></a>
<a href="https://travis-ci.org/kawoou/Deli"><img src="https://travis-ci.org/kawoou/Deli.svg?branch=master" alt="CI Status"/></a>
<a href="http://kawoou.kr/Deli"><img src="http://kawoou.kr/Deli/badge.svg" alt="Jazzy"/></a>
<a href="http://cocoadocs.org/docsets/Deli"><img src="https://img.shields.io/cocoapods/p/Deli.svg?style=flat" alt="Platform"/></a>
</p>

Deli는 쉽게 사용할 수 있는 DI Container 프로젝트입니다.

> Language Switch: [English](https://github.com/kawoou/Deli/tree/master/README.md), [한국어](https://github.com/kawoou/Deli/tree/master/README_KR.md).




## 목차
* [개요](#개요)
* [시작하기](#시작하기)
  - [Build Phases](#build-phases)
* [기능](#기능)
  - [Component](#1-component)
  - [Autowired](#2-autowired)
  - [LazyAutowired](#3-lazyautowired)
  - [Configuration](#4-configuration)
  - [Inject](#5-inject)
  - [Factory](#6-factory)
  - [ModuleFactory](#7-modulefactory)
    - [Multi-Container](#71-multi-container)
    - [Unit Test](#72-unit-test)
  - [Struct](#8-struct)
  - [Configuration Property](#9-configuration-property)
    - [사용법](#91-사용법)
    - [묶음 값](#92-묶음-값)
    - [단일 값](#93-단일-값)
    - [프로퍼티에 의한 주입](#94-프로퍼티에-의한-주입)
  - [Property Wrapper](#10-propertywrapper)
    - [Dependency](#101-dependecy)
    - [PropertyValue](#102-propertyvalue)
* [설치 방법](#설치-방법)
  - [Cocoapods](#cocoapods)
  - [Carthage](#carthage)
  - [Command Line](#command-line)
* [예제](#예제)
* [기여 방법](#기여-방법)
* [요구사항](#요구사항)
* [Attributions](#attributions)
* [License](#license)



## 개요

우리는 언제나 실수를 저지를 수 있으며 잘못된 코드를 작성할 수 있습니다. 당신은 프로젝트가 커지면서 복잡성이 늘어나는 것을 경험한 적이 있을 것입니다.

[Spring framework](https://github.com/spring-projects/spring-framework)에서는 Annotation을 이용하여 자동 등록 기능을 제공하는 것뿐만 아니라 Dependency Graph의 문제를 알려줍니다. 저는 이 기능을 Swift에도 녹여내고 싶었습니다.




## 시작하기

`deli.yml`이라는 설정 파일을 만들어 봅시다.

만약 설정 파일이 존재하지 않는다면, 현재 폴더의 유일한 프로젝트의 빌드 타겟을 찾습니다. 이것은 `scheme`, `target`, 그리고 `output` 필드를 지정하지 않았을 때와 비슷하게 동작합니다.

```yaml
target:
  - MyProject

config:
  MyProject:
    project: MyProject
    scheme: MyScheme
    include:
      - 추가할 파일들...
    exclude:
      - 제외할 파일들...
    className: DeilFactory
    output: Sources/DeliFactory.swift
    resolve:
      output: Deli.resolved
      generate: true
    dependencies:
      - path: Resolved 파일들...
        imports: UIKit
    accessControl: public
```

당신이 지정한 빌드 Scheme은 `Shared`로 설정되어야 합니다. Xcode의 `Manage Scheme`에서 `Shared` 영역을 확인합시다:

![shared-build-scheme](https://github.com/kawoou/Deli/raw/screenshot/shared-build-scheme.png)

또 다른 방법으로 `scheme` 대신 `target`을 지정할 수도 있습니다. 이 경우에 Deli는 Build Target을 찾게됩니다.

그리고, 제공된 바이너리를 통해 빌드합니다.

```bash
$ deli build
```

Dependency Graph는 소스코드 정적 분석을 통해 구성됩니다. 그리고 이것은 당신이 지정한 파일 혹은 폴더에 저장됩니다.

만들어진 파일은 다음과 같습니다:

```swift
//
//  DeliFactory.swift
//  Auto generated code.
//

import Deli

final class DeliFactory: ModuleFactory {
    override func load(context: AppContextType) {
        ...
    }
}
```

생성된 파일을 프로젝트에 추가하고, 앱의 시작 지점에서 불러줍니다.

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

Deli를 Xcode 스킴에 통합하여 IDE 상에 경고와 에러를 표시할 수 있습니다.
새로운 "Run Script Phase"를 만들고 아래의 스크립트를 추가하면 됩니다:

```bash
if which deli >/dev/null; then
  deli build
else
  echo "error: Deli not installed, download from https://github.com/kawoou/Deli"
fi
```

![Build Phase](https://github.com/kawoou/Deli/raw/screenshot/xcode-run-script.png)

CocoaPods를 사용해서 설치한 경우에는 아래의 스크립트를 대신 사용합니다:

```bash
"${PODS_ROOT}/DeliBinary/deli" build
```



## 기능
### 1. Component
`Component` 프로토콜은 class, struct, protocol이 확장할 수 있으며, 확장한 구현체는 자동으로 DI container에 등록됩니다.

`Component`는 다음과 같이 사용합니다:

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

위와 같은 코드가 작성되어 있다면, 당신은 `UserService`나 `UserServiceImpl` 타입을 사용해 의존성 구현체의 인스턴스를 로드할 수 있습니다.



### 2. Autowired

`Autowired` 프로토콜도 자동으로 등록된다는 점에서 `Component` 프로토콜과 비슷합니다. 다른 점이 있다면, 로드 시에 의존성을 주입받을 수 있다는 점입니다.

`Autowired`는 다음과 같이 사용합니다:

```swift
class LoginViewModel: Autowired {
    let userService: UserService

    required init(_ userService: UserService) {
        self.userService = userService 
    }
}
```

간단하죠? 그럼 이제 아래의 코드를 봅시다:

```swift
protocol Book {
    var name: String { get }
    var author: String { get }
    var category: String { get }
}

class Novel: Book {
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

class HarryPotter: Novel, Component {
    override var name: String {
        return "Harry Potter"
    }
    
    override var author: String {
        return "J. K. Rowling"
    }
}

class TroisiemeHumanite: Novel, Component {
    override var name: String {
        return "Troisième humanité"
    }
    
    override var author: String {
        return "Bernard Werber"
    }
}
```

이 코드는 상속을 통해 책들을 정리하고 있습니다. 당신은 아래와 같이 `Book` 타입을 이용해 모든 책의 인스턴스를 받아올 수 있습니다:

```swift
class LibraryService: Autowired {
    let books: [Book]

    required init(_ books: [Book]) {
        self.books = books
    }
}
```

더 나아가서, "Novel" Qualifier가 지정된 책들을 가져오기 위해서는 어떡해야할까요?
Deli에서는 아래와 같이 생성자 주입받을 수 있습니다:

```swift
class LibraryService: Autowired {
    let books: [Book]

    required init(Novel books: [Book]) {
        self.books = books
    }
}
```



### 3. LazyAutowired

순환 참조가 발생하지 않는 것이 가장 좋겠지만, 프로덕트를 개발하다보면 완전히 배제할 수는 없는 문제입니다. 문제를 해결하기 위한 간단한 방법은 하나의 의존성을 느리게 로드하는 방법이 있습니다.

그럼 `LazyAutowired` 프로토콜을 사용해봅시다:

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

만약 당신이 MessageService를 주입받고자 하면 순환 참조 에러를 마주하게 됩니다.

```bash
$ deli validate

Error: The circular dependency exists. (MessageService -> FriendService -> UserService -> MessageService)
```

그럼 UserService가 `LazyAutowired`를 확장한다면 어떨까요?

```swift
class UserService: LazyAutowired {
    let messageService: MessageService!

    func inject(_ messageService: MessageService) {
        self.messageService = messageService
    }

    required init() {}
}
```

순환 고리가 끊어지고 이슈가 해결되었습니다!
MessageService가 성공적으로 생성된 이후에 필요로하는 UserService 의존성은 `inject()` 메소드를 통해 주입됩니다.

추가적으로 LazyAutowired도 Autowired와 같이 Qualifier를 지정할 수 있습니다. 아래의 코드는 "facebook" Qualifier가 지정된 UserService 인스턴스를 받아옵니다:

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

`Configuration` 프로토콜은 사용자가 직접 `Resolver`를 직접 등록할 수 있도록 해줍니다.

아래의 코드를 봅시다:

```swift
class UserConfiguration: Configuration {
    let networkManager = Config(NetworkManager.self, ConfigurationManager.self) { configurationManager in
        let privateKey = "1234QwEr!@#$"
        return configurationManager.make(privateKey: privateKey)
    }

    init() {}
}
```
ConfigurationManager에 privateKey를 넘겨 NetworkManager를 생성하는 모습을 볼 수 있습니다.

이 NetworkManager 인스턴스는 DI container에 등록되고, `singleton` Scope로써 관리됩니다.
(그러나, 이 동작은 scope 인자를 변경하여 바꿀 수 있습니다.)



### 5. Inject

설명했듯이, `Autowired`는 DI container에 등록됩니다. 그러나 등록하지 않고 사용하고 싶을 수도 있습니다. 이 때 사용하는 것이 `Inject`입니다.

```swift
class LoginView: Inject {
    let viewModel = Inject(LoginViewModel.self)

    init() {}
}

class NovelBookView: Inject {
    let novels: [Book] = Inject([Book].self, qualifier: "Novel")

    init() {}
}
```


### 6. Factory

Front-end에서는 유동적으로 사용자의 데이터를 이용하여 모델을 생성하는 경우가 많습니다. 예를 들어봅시다.

당신은 친구 목록을 구현해야합니다. 친구 목록에서 하나의 셀을 선택하면, 친구의 정보를 볼 수 있는 모달이 떠야합니다.
이때 `정보 모달`에는 친구를 특정할 수 있는 데이터가 전달되어야 합니다.

이런 상황은 매우 빈번하게 발생하는 플로우이며, Factory들은 이를 도와줍니다.

먼저 `AutowiredFactory`를 살펴봅시다:

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

User-argument를 넘기기 위해서 `Payload`라는 프로토콜을 구현해야 합니다.
(당연하게도 Factory들은 prototype scope로 동작합니다)

구현된 `FriendInfoViewModel`는 다음과 같이 사용할 수 있습니다:

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

Swift 타입 추론에 의해서 `with:` argument 부분에 대한 스타일이 강제화된 모습을 볼 수 있습니다.

다음으로 LazyAutowiredFactory를 살펴봅시다:

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

AutowiredFactory와 LazyAutowiredFactory 간의 차이점은 Autowired와 LazyAutowired와의 관계랑 같이 Lazy하게 주입된다는 점입니다.
그렇지만 Payload는 사용자에 의해 전달받으므로 생성자를 통해 주입합니다.



### 7. ModuleFactory

Container를 통한 의존성 주입시에는 설계도가 필요합니다.
그 설계도는 위에서 이야기했듯이 `빌드`라는 과정을 통해서 만들어집니다(ex. DeliFactory).
만들어진 클래스는 `AppContext#load()` 호출 시, 클래스가 상속받고 있는 `ModuleFactory` 안에 들어있는 Container에 로드시킵니다.

Deli는 Multi-Container를 제공합니다.
그래서 다음과 같은 상황에서 ModuleFactory를 활용할 수 있습니다.



#### 7.1. Multi-Container

`AppContext#load()`를 호출할 때 모듈 안에 들어있는 `ModuleFactory`도 로드해주면 됩니다.

이 경우 추가적으로 `LoadPriority`를 지정할 수 있습니다. 이는 의존성 주입 시에 사용되어질 Container를 선택하는 기준이 됩니다.

Priority는 기본적으로 `normal(500)`이며 Container의 선택되는 순서는 다음과 같습니다.

1. 우선 순위가 높을수록 우선적으로 사용합니다.

```swift
AppContext.shared.load([
    OtherModule.DeliFactory.self,
    DeliFactory.self
])
```

2. 같은 우선 순위일 경우, 등록한 순서대로 사용합니다.

```swift
AppContext.shared
    .load(DeliFactory())
    .load(OtherModule.DeliFactory(), priority: .high)
```



#### 7.2. Unit Test

[7.1](#71-multi-container)의 내용과 같이 우선 순위 로드를 Unit Test 시에도 활용할 수 있습니다.

``` swift
import Quick
import Nimble

@testable import MyApp

class UserTests: QuickSpec {
    override func spec() {
        super.spec()

        let testModule: ModuleFactory!
        testModule.register(UserService.self) { MockUserService() }

        let appContext = AppContext.shared
        beforeEach {
            appContext.load(testModule, priority: .high)
        }
        afterEach {
            appContext.unload(testModule)
        }
        
        ...
    }
}
```

테스트 코드에 대한 예시는 `Deli.xcodeproj`에서 확인할 수 있습니다.



### 8. Struct

버전 `0.7.0`부터 Class 뿐만 아니라 Struct에 대한 지원이 추가되었습니다.

기본적인 동작은 Class일 때와 동일하나, 한가지 차이점은 `weak` Scope를 사용할 수 없다는 점이 있습니다.

아래는 [Moya](https://github.com/Moya/Moya)의 Plugin을 구현한 예시입니다.

```swift
struct AuthPlugin: PluginType, LazyAutowired {

    var scope: Scope = .weak

    private let authService: AuthService!

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request

        if let authToken = authService.authToken {
            request.addValue(authToken.accessToken, forHTTPHeaderField: "Authorization")
            request.addValue(authToken.refreshToken, forHTTPHeaderField: "Refresh-Token")
        }

        return request
    }

    mutating func inject(_ authService: AuthService) {
        self.authService = authService
    }

    init() {}
}
```



### 9. Configuration Property

앱이 실행되는 환경에 따라 다른 구성 값을 사용하는 것이 유용한 경우가 많습니다.
예를 들면 로그가 저장하는 곳을 개발 빌드에서는 파일로, Release 빌드에서는 저장하지 않도록 해볼수도 있겠죠.

**application-dev.yml:**
```yaml
logger:
    storage: file

server:
    url: https://dev.example.com/api
    isDebug: false
```

**application-prod.yml:**
```yaml
logger:
    storage: default

server:
    url: https://www.example.com/api
    isDebug: true
```



#### 9.1. 사용법

위에서 만든 Configuration Property 사용을 위해선 `deli.yml`을 변경하거나, 빌드 스크립트를 수정하는 두 가지 방법이 있습니다.

설정 파일을 변경하는 방식은 아래와 같이할 수 있습니다:

```yaml
target:
- MyApp

config:
  MyApp:
    - project: MyApp
    - properties:
      - Configurations/Common/*.yml
      - Configurations/application-dev.yml
```

빌드 스크립트로는 이렇게 할 수 있습니다:

```bash
deli build \
  --property "Configurations/Common/*.yml" \
  --property "Configurations/application-dev.yml"
```

만약 같은 설정 정보가 있는 경우 마지막에 지정된 정보로 덮어쓰기 됩니다.



#### 9.2. 묶음 값

설정 파일로 지정한 값을 안전하게 받아오기 위해 `ConfigProperty`를 사용할 수 있습니다.

```swift
struct ServerConfig: ConfigProperty {
    let target: String = "server"

    let url: String
    let isDebug: Bool
}
```

위와 같이 모델을 구현한 경우, `ServerConfig`는 IoC Container에 등록되며 주입받을 경우 자동으로 설정 값을 담아서 주입됩니다.

모델을 정의할 때 유의할 점이 있다면, `target`이라는 값을 설정해줘야 한다는 점입니다. 이 Property는 설정 파일에서 받아올 경로를 나타내며 JSONPath 스타일로 입력합니다.

만약 빌드시에 모델에서 요구하는 설정 값이 없다면 컴파일 에러를 볼 수 있습니다.

```swift
final class NetworkManager: Autowired {
    let info: ServerConfig

    required init(_ config: ServerConfig) {
        info = config
    }
}
```



#### 9.3. 단일 값

묶음 값을 받아오는 경우에는 `ConfigProperty`라는 프로토콜을 구현하는 방식으로 처리했다면, 단일 값을 가져올 때는 `InjectProperty`가 있습니다.

```swift
final class NetworkManager: Inject {
    let serverUrl = InjectProperty("server.url")
}
```

`InjectPropety`도 `ConfigProperty`와 동일하게 빌드 시에 설정 값을 확인하며, String 타입으로 데이터를 주입합니다.

그렇지만 설정 값을 검증없이 Optional 값으로 가져오고 싶다면 적합한 방법이 아닙니다.

이 경우 `AppContext#getProperty()` 메소드를 사용하여 처리하는 것이 좋습니다.

```swift
final class NetworkManager {
    let serverUrl = AppContext.getProperty("server.url", type: String.self) ?? "https://wtf.example.com"
}
```



#### 9.4. 프로퍼티에 의한 주입

Deli에서는 Configuration Property의 사용성을 높이기 위해, 설정 값을 `qualifier`로 이용하여 로드하는 방법을 제공합니다.

사용에는 두 가지 방법이 있는데 `Autowired`와 같이 생성자 주입을 하는 경우에 대한 방법을 먼저 설명합니다.

[Autowired](#2-autowired) 단락에서 설명했듯이 `qualifier`를 지정하는 부분에는 `.`를 사용하지 못합니다. 안타깝지만 Annotation와 유사한 기능이 제공되지 않습니다. 그러므로 주석을 이용하는 방법으로 구현되었습니다.

사용법은 아래와 같습니다:

```swift
final class UserService: Autowired {
    required init(_/*logger.storage*/ logger: Logger) {
    }
}
```

`Inject` 메소드를 활용할 때는 다음과 같습니다:

```swift
final class UserService: Inject {
    func getLogger() -> Logger {
        return Inject(Logger.self, qualifierBy: "logger.storage")
    }
}
```



### 10. PropertyWrapper

좀 더 간편한 사용을 위해 Swift 5.1에 추가된 [@propertyWrapper](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md)를 지원합니다.

지원하는 기능은 크게 두 가지가 있는데, 의존성을 주입받는 것과 [Configuration Property](#9-configuration-property)를 주입받는 것 두 가지입니다.



#### 10.1. Dependency

의존성에 대한 주입은 크게 `@Dependency`와 `@DependencyArray`로 나눠집니다.

```swift
class Library {
    @Dependency(qualifier "logger.storage")
    var logger: Logger

    @DependencyArray(qualifier: "novel")
    var novels: [Book]
}
```



#### 10.2. PropertyValue

`@PropertyValue`는 [Configuration Property](#9-configuration-property)와 동일하며 사용법은 아래와 같습니다.

```swift
final class NetworkManager: Inject {
    @PropertyValue("server.url")
    let serverUrl: String
}
```



## 설치 방법

### [Cocoapods](https://cocoapods.org/):

Podfile에 아래 라인을 추가하기만 하면 됩니다.

```ruby
pod 'Deli', '~> 0.8.1'
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



## 예제

 * [DeliTodo](https://github.com/kawoou/DeliTodo): Todo application for iOS using Deli.
 * [GitHubSearch](https://github.com/kawoou/Deli/tree/master/Examples/GitHubSearch): GitHub Search example using Deli.
 * [Survey](https://github.com/kawoou/Deli/tree/master/Examples/Survey): Survey example using Deli.
 * [RobotFactory](https://github.com/kawoou/Deli/tree/master/Examples/RobotFactory): RobotFactory example using Deli.



## 기여 방법

토론이나 PR은 어떤 것이든 환영합니다.

[PR 등록을 통해](https://github.com/kawoou/Deli/compare) 프로젝트에 기여해주세요!



## 요구사항

* Swift 3.1+



## Attributions

이 프로젝트는 아래의 프로젝트를 사용하고 있습니다.

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
 * [Quick](https://github.com/Quick/Quick)
   - Apache License 2.0
   - Created by [Quick Team](https://github.com/Quick)
 * [Nimble](https://github.com/Quick/Nimble)
   - Apache License 2.0
   - Created by [Quick Team](https://github.com/Quick)



## License

Deli is under MIT license. See the [LICENSE](https://github.com/kawoou/Deli/blob/master/LICENSE) file for more info.

