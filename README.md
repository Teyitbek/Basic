# Basic

A playground for exploring SwiftUI, testing and app architecture.

It is not trying to be a product. Each feature is an excuse to try something
properly and keep it: a navigation pattern, a loading state, an accessibility
API, a layout that has to adapt. Where a decision was not obvious, the reason
is written down next to the code rather than in a commit nobody will reopen.

The app itself browses the [jsonplaceholder](https://jsonplaceholder.typicode.com)
API: sign in, pick an endpoint from a list, see what it returns.

## Running it

Open `Basic.xcodeproj` and run. `Cmd + U` runs the tests.

| | |
|---|---|
| Minimum iOS | 26.0 |
| Swift | 5 language mode, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` |
| Dependency | [RealHTTP](https://github.com/immobiliare/RealHTTP) |
| Languages | English (source), Russian |

The login screen takes any name, email and password that pass validation, or
**Skip** to go straight in.

## Architecture

SwiftUI all the way down. There is no coordinator and no `UIViewController`.

**Navigation lives where the tap does.** `RootView` owns the single
`NavigationStack`; a row is a `NavigationLink` carrying a value, and a
`.navigationDestination` beside the list turns that value into a screen. The
endpoint-to-screen mapping sits in `HomeView`, next to the list that triggers
it.

**View models are `@Observable` and hold no SwiftUI types.** `LoginVM` is a
plain class with strings on it, so the interesting half of a screen is testable
without a screen. Repositories are passed *to* `load(using:)` rather than
stored, which sidesteps needing the environment at init time and makes the
tests one-liners.

**Services reach views through the environment** (`@Environment(\.services)`)
instead of being threaded down from a factory.

```
Basic/
├── App/              BasicApp, RootView — the one NavigationStack
├── Features/         one folder per screen: a View, a VM, and its own helpers
└── Services/         models, requests, data sources, repositories
```

## Things worth looking at

**Adaptive tab bar** — `TabbarView` puts the bar across the bottom, or down the
trailing edge when the screen is wide enough. It decides on the screen's
*proportions*, not the device model: an unfolded iPhone Duo reports a
`.compact` size class exactly like any other phone, and at 466pt wide it is
only 26pt wider than an iPhone 17 Pro Max — but its 0.69 width-to-height ratio
is nothing like a phone's 0.46. Everything that exists only for that mode is
marked `// iPhone Duo`.

**`NotchedBarShape`** — the bar's outline dips around the centre button in an
arc concentric with it, so the gap is even the whole way round, with tangent
shoulder arcs either side so there are no corners.

**`SkeletonView`** — placeholder blocks mirroring the real layout, with one
gradient masking the whole view so the shimmer reads as a single wave rather
than several independent blinks. It stays up for one full sweep minimum, since
a fast response otherwise flashes it for a frame and reads as a glitch.

**Accessibility** — the details screen groups its header into one VoiceOver
element, splits each row into label and value, supports Dynamic Type, and
offers the long-press magnifier via `accessibilityShowsLargeContentViewer`.

## Testing

52 tests. [TESTING.md](TESTING.md) is a written-from-scratch guide to them —
what a unit test is, how to run them, and how this project handles the awkward
parts (faking the network, `async` tests, what is deliberately left untested).

The short version: test decisions, not decoration. Validation rules, data
mapping and loading states are covered; SwiftUI view bodies and navigation are
not, because they are values describing a layout with nothing to assert on.

## Two things that bit, and the fixes

Both were found by the tests or by actually running the app, and both are easy
to hit again:

**A `@MainActor` class storing an `async` closure crashes on release.** The
target's default actor isolation gives such a class an isolated `deinit`, and
releasing it aborts in the Swift runtime. `EndpointDetailsView` is a struct —
no `deinit` — so it holds the `DetailsSource` and passes it to the view model
only as an argument.

**`NavigationLink(destination:)` silently breaks `navigationDestination`.** A
view pushed that way never registers its own destinations, so every link inside
it becomes a dead tap that leaves the row highlighted. Push values, not views.

## Conventions

Commits explain *why*, especially where the reasoning would be expensive to
reconstruct. This README is kept current as the project changes.
