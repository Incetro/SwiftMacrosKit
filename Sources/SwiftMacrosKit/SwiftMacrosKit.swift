// The Swift Programming Language
// https://docs.swift.org/swift-book

/// Automatically generates closures to manage dynamic string properties, useful for localization.
///
/// This macro:
/// - Adds closures for properties defined as `String` or `String?`.
/// - Provides a dynamic accessor through closures, allowing you to manage localization dynamically.
/// - For non-optional properties, ensures that the property always returns a non-optional `String` value.
///
/// Example usage:
/// ```swift
/// @DynamicStringWrapper
/// public struct SomeStruct {
///     public var optionalString: String?
///     public var string: String
/// }
/// ```
///
/// Result:
/// ```swift
/// public struct SomeStruct {
///
///     @ClosureAccessor
///     public var optionalString: String?
///
///     @ClosureAccessor
///     public var string: String
///
///     public init(
///         optionalString: @autoclosure @escaping () -> String? = {
///             nil
///         }(),
///         string: @autoclosure @escaping () -> String
///     ) {
///         self.optionalStringClosure = optionalString
///         self.stringClosure = string
///     }
///
///     public static func == (lhs: SomeStruct, rhs: SomeStruct) -> Bool {
///         return lhs.optionalString == rhs.optionalString && lhs.string == rhs.string
///     }
/// }
/// extension SomeStruct: Equatable {
/// }
/// ```
@attached(member, names: arbitrary)
@attached(extension, conformances: Equatable)
@attached(memberAttribute)
public macro DynamicStringWrapper() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DynamicStringWrapperMacro")

/// Adds a computed `get` accessor that retrieves values from a closure.
///
/// This macro creates a backing closure for the property and a `get` accessor.
/// The accessor uses the closure to fetch the current value whenever the property is accessed.
///
/// Example usage:
/// ```swift
/// @ClosureAccessor
/// public var greeting: String
/// ```
///
/// Result:
/// ```swift
/// private let greetingClosure: () -> String
///
/// public var greeting: String {
///     greetingClosure()
/// }
/// ```
/// Here, `greeting` uses `greetingClosure` to fetch the latest value on access.
@attached(accessor)
public macro ClosureAccessor() = #externalMacro(module: "SwiftMacrosKitMacros", type: "ClosureAccessorMacro")

/// Adds automatic localization updates to a SwiftUI `View`, refreshing it upon locale changes.
///
/// This macro:
/// - Subscribes the `View` to localization notifications, refreshing its content as needed.
/// - Provides a seamless way to manage language or locale changes within a `View` in SwiftUI.
///
/// Example usage:
/// ```swift
/// @WithLocalizationUpdater
/// public struct SomeView: View {
///
///     public var body: some View {
///         Text("Hello world!")
///     }
/// }
/// ```
///
/// Result:
/// ```swift
/// public struct SomeView: View {
///     @ObservedObject private var localizationUpdater = LocalizationViewUpdater()
///
///     public var body: some View {
///         Text("privet")
///     }
/// }
/// ```
///
/// In this example, `localizationUpdater` observes locale changes and triggers a SwiftUI view update automatically.
@attached(member, names: arbitrary)
public macro WithLocalizationUpdater() = #externalMacro(module: "SwiftMacrosKitMacros", type: "WithLocalizationUpdaterMacro")
