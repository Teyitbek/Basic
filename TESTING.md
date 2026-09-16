# Unit testing — a beginner's guide to this project

You have never written a unit test before, so this file explains the idea from
scratch and then walks through the tests that now exist in the project.

---

## 1. What is a unit test, really?

A unit test is **just a small function that runs a piece of your code and
checks the answer**. Nothing more mysterious than that.

You already test your code — by running the app, tapping through to a screen,
and looking at it. That works, but it is slow, you have to remember to do it,
and you only check the one path you happened to walk. A unit test does the
same check in a few milliseconds, automatically, every time, forever.

The three things a test gives you:

1. **It proves the code works** for the cases you thought of.
2. **It stops you breaking it later.** This is the big one. In six months you
   will change the login validation, and a test will tell you instantly that
   you broke the "password must contain a number" rule.
3. **It documents intent.** `test_login_withOneLetterName_showsTooShortError`
   tells the next person what the rule is, better than a comment would.

---

## 2. How to run them

| What | How |
|---|---|
| Run every test | `Cmd + U` in Xcode |
| Run one file | Click the diamond ◇ next to the class name |
| Run one test | Click the diamond ◇ next to the test method |
| See results | The Test navigator, `Cmd + 6` |

Green diamond = passed. Red = failed, and Xcode shows you the exact line.

From the terminal:

```bash
xcodebuild test -project ToDoTabbar.xcodeproj -scheme ToDoTabbar -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## 3. The anatomy of a test file

Open `ToDoTabbarTests/LoginVMTests.swift` and follow along:

```swift
final class LoginVMTests: XCTestCase {     // 1

    private var sut: LoginVM!              // 2

    override func setUp() {                // 3
        super.setUp()
        sut = LoginVM()
    }

    override func tearDown() {             // 4
        sut = nil
        super.tearDown()
    }

    func test_login_withEmptyName_showsRequiredError() {   // 5
        sut.name = ""
        sut.email = "teyit@example.com"
        sut.password = "secret123"

        sut.login()

        XCTAssertEqual(sut.nameError, "Name is required")   // 6
    }
}
```

1. **`XCTestCase`** — Xcode finds every class that inherits from it and treats
   it as a group of tests.
2. **`sut`** — "system under test". A conventional name for the object the
   file is about. You will see it in every codebase.
3. **`setUp`** — runs before *each* test. Xcode creates a brand new instance
   of the test class for every test method, so nothing leaks between tests.
   Tests can therefore run in any order.
4. **`tearDown`** — runs after each test. Setting things to `nil` here keeps
   memory clean and surfaces retain cycles.
5. **`func test...`** — a method whose name starts with `test` and takes no
   arguments *is* a test. That is the whole rule.
6. **`XCTAssert...`** — the actual check. If it holds, the test passes.

### Naming

The convention used here is:

```
test_<what you do>_<what should happen>
```

`test_getUsers_onFailure_publishesAnErrorAndKeepsUsersEmpty` reads like a
sentence in the test report. When it goes red you know what broke without
opening the file.

### The Given / When / Then shape

Most tests have three parts, and the tests in this project mark them with
comments:

```swift
// GIVEN — the starting situation
repository.getUsersResult = .success([Fixtures.user()])

// WHEN — the thing being tested happens
await sut.load(using: repository)

// THEN — check the outcome
XCTAssertEqual(sut.users.count, 1)
```

---

## 4. The assertions you will actually use

| Assertion | Passes when |
|---|---|
| `XCTAssertEqual(a, b)` | `a == b` — the workhorse |
| `XCTAssertTrue(x)` / `XCTAssertFalse(x)` | `x` is true / false |
| `XCTAssertNil(x)` / `XCTAssertNotNil(x)` | `x` is nil / is not nil |
| `XCTFail("message")` | never — call it when you reach a branch that should be impossible |

Every one takes an optional message as the last argument. Use it when a test
loops over several inputs, so a failure tells you *which* input broke:

```swift
XCTAssertEqual(sut.emailError, "Enter a valid email", "failed for: \(email)")
```

---

## 5. The hard parts, and how this project handles them

### 5a. Code that talks to the network

`UsersVM.load(using:)` calls a repository that calls jsonplaceholder.typicode.com.
A unit test must never do that: it would be slow, need Wi-Fi, and fail for
reasons unrelated to your code. And you could never test what happens when the
server returns an error.

The fix is **dependency injection with a protocol**:

```swift
protocol UsersRepositoryProtocol {
    func getUsers() async throws -> [User]
}
```

`UsersVM` takes that protocol, not the concrete `UsersRepository`. In the app
the view hands it `Services.live` from the environment; in tests we pass a fake:

```swift
final class MockUsersRepository: UsersRepositoryProtocol {
    var getUsersResult: Result<[User], Error> = .success([])

    func getUsers() async throws -> [User] {
        try getUsersResult.get()     // throws when the result is .failure
    }
}
```

Now the test decides what "the server" returns — including a failure. This is
the single most useful testing technique there is, and it is why those two
protocols were added to the project.

> **Vocabulary:** a fake object used in a test is a *test double*. You will
> hear *mock*, *stub*, *fake*, and *spy* used for slightly different flavours.
> Do not worry about the distinction yet — people use them interchangeably.

### 5b. Code that finishes later (async)

`load(using:)` is an `async` function: it starts, waits for the network, and
finishes later. A plain test would check the result before the work is done.

The fix is one keyword. Mark the test `async` and `await` the call:

```swift
func test_load_onSuccess_storesTheUsers() async {
    repository.getUsersResult = .success([Fixtures.user()])

    await sut.load(using: repository)      // the test pauses here

    XCTAssertEqual(sut.users.count, 1)     // safe to check
}
```

That is the whole technique. XCTest runs `async` tests properly and waits for
them, so there are no callbacks, no expectations, and no timeouts to tune.

> You may see `XCTestExpectation` in older code and tutorials — create it,
> `fulfill()` it in a callback, `wait(for:)` on it. That is what you need when
> the code reports back through a closure or a Combine publisher instead of
> `async`. This project no longer has any of those.

---

## 6. What is tested in this project, and why

| File | Covers | Why it is worth testing |
|---|---|---|
| `LoginVMTests` | every validation rule, and whether login is allowed | Pure logic with many branches — the ideal unit test target. 15 tests. |
| `EndpointTests` | `url`, `title`, `listTitle` | String building that is easy to break silently. |
| `DetailsMappingTests` | `User -> Details`, `Post -> Details` | Where a wrong label or a forgotten field would hide. |
| `DetailsAccessibilityTests` | the wording VoiceOver speaks | A missing space or a dangling comma is audible but invisible. |
| `HomeVMTests` | the endpoint list contents | Protects the data the Home screen shows. |
| `UsersVMTests` / `PostsVMTests` | loading success **and** failure, and not refetching | The failure path is the one you can never reproduce by hand. |
| `EndpointDetailsVMTests` | `.ready` vs `.remote`, success, error, skeleton timing | Two modes, so two sets of behaviour to pin down. |
| `ToDoTabbarUITests/LoginUITests` | the app launches and shows the login screen | One slow end-to-end smoke test. |

### What is deliberately *not* tested

* **The SwiftUI views themselves.** A `View` is a value describing a layout;
  there is no object to poke at from a unit test. Checking that a font is
  `.headline` or a stack has 6pt spacing is busywork that breaks on every
  design tweak. Look at the screen, or at an Xcode preview, instead.
* **Navigation.** `NavigationLink(value:)` and `.navigationDestination` are
  SwiftUI's job. What *is* tested is the data those links carry.
* **Data sources / `RealHTTP` requests** — those test Apple's and RealHTTP's
  code, not yours.

The general rule: **test decisions, not decoration.** Anywhere your code says
"if this then that", or transforms one shape of data into another, is worth a
test. Layout and plumbing usually are not.

That line is also why the view models hold no SwiftUI types. `LoginVM` is a
plain class with strings on it, so the interesting half of the login screen is
testable without a screen at all.

---

## 7. Adding your own test

Say you add a "confirm password" field. You would:

1. Open `LoginVMTests.swift`.
2. Copy the nearest existing test.
3. Rename it to say what it checks:
   `test_login_withMismatchedPasswords_showsMismatchError`.
4. Change the input and the expected message.
5. `Cmd + U`.

A useful habit once you are comfortable: write the test *first*, watch it fail
for the right reason, then write the code that makes it pass. That is called
TDD. It is not compulsory, but it guarantees your test can actually detect the
bug it claims to.

---

## 8. One project setting worth knowing about

The app target is built with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which
makes every type in the app `@MainActor` automatically. The test target did not
have that setting, so the two modules disagreed about the app's types. It is now
set on the test target too, so they match.

That same setting has one sharp edge worth remembering: a `@MainActor` class
that *stores* an `async` closure gets an isolated `deinit`, and releasing one
crashes in the Swift runtime. The unit tests caught this the first time it
happened. It is why `EndpointDetailsView` — a struct, which has no `deinit` —
holds the `DetailsSource`, and passes it to the view model only as an argument.

---

## 9. Trying the accessibility features by hand

Some things can only be checked with your own eyes and ears. For the details
screen:

**VoiceOver** — Settings ▸ Accessibility ▸ VoiceOver ▸ on. (On a device, triple-click
the side button to toggle it quickly.) Swipe right to move between elements.
The header should read as one phrase — *"Leanne Graham, leanne@example.com,
heading"* — and each row as *"Username, Bret"*, not as two separate stops.

**The long-press magnifier** (large content viewer) — it is deliberately
invisible until the user needs it, so you must first choose an accessibility
text size: Settings ▸ Accessibility ▸ Display & Text Size ▸ Larger Text, turn on
*Larger Accessibility Sizes*, and drag the slider to one of the last few
positions. Then press and hold any row on the details screen: a magnified HUD
appears in the middle of the screen and follows your finger from row to row.

On the simulator you can set the text size from the terminal instead:

```bash
xcrun simctl ui booted content_size accessibility-extra-large
```

and put it back with `content_size large`.
