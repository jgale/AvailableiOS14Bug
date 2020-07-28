I've made a GitHub repo that reproduces the example: https://github.com/jgale/AvailableiOS14Bug. I've also attached a .zip here, and pasted the code inline.

# Background

I have a SwiftUI app that has a minimum deployment target of iOS 13.5. I am trying to ensure my app will work properly on iOS 14.

One of the iOS 14 problems I've encountered is that `Text` elements in a `Section` header are automatically capitalized by default. This has lead to significant portion of my app being in ALLCAPS. I'm trying to fix this in a way that works on both iOS 13 and 14. I'm making use of the new `.textCase(nil)` API in iOS 14, but I want to do it in a conditional way because it's not available on iOS 14.

# Steps to Reproduce

Create a `ViewModifier` struct that checks for the presence of iOS 14:

```swift
struct NormalCaseHeader: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content.textCase(nil)
        } else {
            content
        }
    }
}
```

I then apply this modifier to my `Section`:

```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("lowercase text")) {
                    Text("Item 1")
                    Text("Item 2")
                }
                .normalCase()
            }
            .navigationBarTitle("#if available bug")
        }
    }
}
```

Expected: 
* The "lowercase text" in the Section header should be all lowercase on both iOS 13 and 14

Actual:
* It works on iOS 14, the Section is not rendered at all. Instead it's just blank.


I've seen others mention this bug on the Apple forms and a Developer Tools Engineer suggested filing a Feedback:
https://developer.apple.com/forums/thread/650818

# Workarounds

I've got a workaround for this where I don't put the `#if available(iOS 14, *)` check in a `View` body, but it's fairly complicated:

```swift
func iOS14Available() -> Bool {
    if #available(iOS 14, *) {
        return true
    } else {
        return false
    }
}

struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
    let value: Bool
    let trueContent: () -> TrueContent
    let falseContent: () -> FalseContent
    var body: some View {
        if value {
            return AnyView(trueContent())
        } else {
            return AnyView(falseContent())
        }
    }
}
extension View {
    func oniOS14<TrueContent: View>(
        content: @escaping (Self) -> TrueContent
    ) -> ConditionalContent<TrueContent, Self> {
        return ConditionalContent(
            value: iOS14Available(),
            trueContent: { content(self) },
            falseContent: { self }
        )
    }
}
```