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

// MARK: - AutoInitMacro

/// A macro that generates a public initializer for a struct, handling various property types,
/// including closures and optional values.
///
/// This macro:
/// - Adds `@escaping` for non-optional closures.
/// - Provides default values for optional closures and optional properties:
///   - If a property is an optional closure (`() -> Value?`), it sets a default value of `{ nil }()`.
///   - If a property is optional (e.g., `String?`), it assigns a default value of `nil`.
///
/// - Properties that are non-optional and not closures are required parameters in the initializer.
///
/// Example usage:
/// ```swift
/// @AutoInit
/// public struct ExampleStruct {
///     public let name: String
///     public let age: Int?
///     public let onComplete: () -> Void
///     public let optionalClosure: (() -> String?)?
/// }
/// ```
///
/// Generated initializer:
/// ```swift
/// public init(
///     name: String,
///     age: Int? = nil,
///     onComplete: @escaping () -> Void,
///     optionalClosure: (() -> String?)? = nil
/// ) {
///     self.name = name
///     self.age = age
///     self.onComplete = onComplete
///     self.optionalClosure = optionalClosure
/// }
/// ```
///
/// - Attributes:
///   - `@attached(member, names: arbitrary)`: This macro attaches additional member declarations,
///     specifically an initializer, to the struct it decorates.
@attached(member, names: arbitrary)
public macro AutoInit() = #externalMacro(module: "SwiftMacrosKitMacros", type: "AutoInitMacro")

// MARK: - DAOMacro

@attached(member, names: arbitrary)
public macro DAOMacro() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DAOMacro")
