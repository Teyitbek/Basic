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
        sut.login(name: "", email: "teyit@example.com", password: "secret123")

        XCTAssertEqual(sut.nameError.value, "Name is required")   // 6
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
sut.getUsers()

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
XCTAssertEqual(sut.emailError.value, "Enter a valid email", "failed for: \(email)")
```

---

## 5. The hard parts, and how this project handles them

### 5a. Code that talks to the network

`UsersVM.getUsers()` calls a repository that calls jsonplaceholder.typicode.com.
A unit test must never do that: it would be slow, need Wi-Fi, and fail for
reasons unrelated to your code. And you could never test what happens when the
server returns an error.

The fix is **dependency injection with a protocol**:

```swift
protocol UsersRepositoryProtocol {
    func getUsers() async throws -> [User]
}
```

`UsersVM` depends on that protocol, not on the concrete `UsersRepository`. In
the app, `AppDelegate` passes the real one. In tests, we pass a fake:

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

`getUsers()` starts a `Task` and publishes on `successGetUsers` some time
afterwards. This test would fail, because the check runs before the work
finishes:

```swift
sut.getUsers()
XCTAssertEqual(sut.users.count, 2)   // still 0 — too early!
```

The tool for this is `XCTestExpectation`:

```swift
let expectation = expectation(description: "successGetUsers is published")

sut.successGetUsers
    .sink { _ in expectation.fulfill() }   // "it happened"
    .store(in: &bag)

sut.getUsers()

wait(for: [expectation], timeout: 1)       // pause until it does

XCTAssertEqual(sut.users.count, 2)         // now it is safe to check
```

Three steps: **create** the expectation, **fulfill** it in the callback,
**wait** for it. If the callback never comes, the test fails after the timeout
instead of hanging forever.

Note `bag`: a Combine subscription is cancelled the moment you stop holding
it, so it must be stored in a `Set<AnyCancellable>` that lives as long as the
test.

### 5c. UIKit work that is queued

`CoordinatorTests` checks that a successful login really leads to the tab bar.
But the coordinator swaps the navigation stack *with an animation*, and UIKit
applies that on the next pass of the run loop — not on the line you call it.

`ToDoTabbarTests/Helpers/WaitHelpers.swift` has a small `wait(until:)` helper
that lets the run loop breathe and re-checks the condition until it becomes
true (or fails after a timeout). It is used like this:

```swift
wait(until: { navigation.viewControllers.first is TabbarVC })
```

---

## 6. What is tested in this project, and why

| File | Covers | Why it is worth testing |
|---|---|---|
| `LoginVMTests` | every validation rule, and whether login is allowed | Pure logic with many branches — the ideal unit test target. 15 tests. |
| `EndpointTests` | `url`, `title`, `listTitle` | String building that is easy to break silently. |
| `DetailsMappingTests` | `User → Details`, `Post → Details` | Where a wrong label or a forgotten field would hide. |
| `HomeVMTests` | the endpoint list contents | Protects the data the Home screen shows. |
| `UsersVMTests` / `PostsVMTests` | loading success **and** failure | The failure path is the one you can never reproduce by hand. |
| `EndpointDetailsVMTests` | `.ready` vs `.remote`, success and error | Two modes, so two sets of behaviour to pin down. |
| `CoordinatorTests` | login → tab bar wiring | Checks the pieces are connected, not just individually correct. |
| `ToDoTabbarUITests/LoginUITests` | the app launches and shows the login screen | One slow end-to-end smoke test. |

### What is deliberately *not* tested

* **Views (`LoginCV`, `HomeCV`, …)** — testing that a label is 18pt or a stack
  view has 6pt spacing is busywork. It breaks on every design tweak and proves
  nothing. Look at the screen instead.
* **Data sources / `RealHTTP` requests** — those test Apple's and RealHTTP's
  code, not yours. If you ever want to cover them, that is an *integration*
  test against a stubbed server, which is a separate topic.
* **`Factory`** — it only calls initialisers.

The general rule: **test decisions, not decoration.** Anywhere your code says
"if this then that", or transforms one shape of data into another, is worth a
test. Layout and plumbing usually are not.

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
have that setting, so the two modules disagreed about the app's types. It has
now been set on the test target too, so they match.

Related: `EndpointDetailsVM` is marked `nonisolated`. Under that MainActor
default, a class storing an `async` closure gets an isolated `deinit`, and
releasing it through that path crashes in the Swift runtime — the unit tests
caught this. The comment above the class explains it. That is a real example of
tests finding a crash that manual tapping did not.

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
