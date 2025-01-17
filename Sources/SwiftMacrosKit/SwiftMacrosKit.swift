// The Swift Programming Language
// https://docs.swift.org/swift-book

import SDAO

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

// MARK: - DAOPlainMacro

/// A macro that generates boilerplate code for plain object models in the context of data persistence.
///
/// This macro:
/// - Generates a database-compatible model (`DatabaseModel`) using Realm.
/// - Creates a translator (`Translator`) for converting between plain objects and database models.
/// - Defines an alias for the `DAO` type for convenient data access.
/// - Ensures the plain object conforms to the `SDAO.Plain` protocol.
///
/// This macro simplifies working with data models by automating the repetitive code needed for database interaction.
///
/// #### Features:
/// - Supports primitive types, enums (`@dao-int-enum`, `@dao-string-enum`), and nested plain objects (`@dao-plain`).
/// - Support ignoring value with `@dao-ignore`
/// - Handles arrays and optional properties.
/// - Provides default values for primitive properties in the generated `DatabaseModel`.
/// - Manages custom translation logic for nested models, enums, and Realm-specific requirements.
///
/// #### Example Usage:
/// ```swift
/// @DAOPlain
/// public struct MyPlainObject: Equatable, Codable {
///
///     public var uniqueId: UniqueID {
///         UniqueID(rawValue: id)
///     }
///
///     // Primitive Properties
///     public let id: String
///     public let name: String
///     public let age: Int
///
///     @dao-ignore
///     public var agePlusTen: Int {
///         age + 10
///     }
///
///     // Enum Properties
///     /// @dao-int-enum
///     public let status: StatusEnum
///
///     /// @dao-string-enum
///     public let type: TypeEnum
///
///     // Array Properties
///     public let tags: [String]
///     public let scores: [Int]
///
///     // Optional Properties
///     public let nickname: String?
///     public let height: Double?
///
///     // Nested Plain Object
///     /// @dao-plain
///     public let details: DetailsPlainObject
///
///     /// @dao-plain
///     public let additionalDetails: [DetailsPlainObject]
/// }
/// ```
///
/// #### Generated Code:
///
/// - **`DatabaseModel`:**
///   A class that represents a Realm-compatible version of the plain object.
///   - Converts plain object properties into types supported by Realm.
///   - Handles optional properties using `RealmProperty` and array properties using `RealmSwift.List`.
///   - Provides default values for primitive types where applicable (e.g., `0` for numbers, `""` for strings).
///   - Maps nested plain objects to their corresponding `DatabaseModel` for database compatibility.
///   - Uses `@objc dynamic` for properties compatible with Realm, ensuring seamless integration.
///
///   Example of a generated `DatabaseModel`:
///   ```swift
///   @objc(MyPlainObjectDatabaseModel)
///   public final class DatabaseModel: RealmModel {
///
///       // MARK: - Properties
///
///       @objc dynamic var id: String = ""
///       @objc dynamic var name: String = ""
///       let tags = RealmSwift.List<String>()
///       @objc dynamic var age: Int = 0
///       @objc dynamic var nickname: String? = nil
///       let scores = RealmSwift.List<Int>()
///       @objc dynamic var details: DetailsPlainObject.DatabaseModel? = nil
///       let additionalDetails = RealmSwift.List<DetailsPlainObject.DatabaseModel>()
///   }
///   ```
///
/// - **`Translator`:**
///   A class that handles data transformation between the plain object and its database model.
///   - **From Plain to Model (`fromPlainToModel`)**:
///     - Prepares a database model for storage by copying plain object values.
///     - Converts enum properties to their raw values for Realm compatibility.
///     - Transforms `URL` properties to `String` for database storage.
///     - Uses translators for nested plain objects to convert them to their respective database models.
///   - **From Model to Plain (`fromModelToPlain`)**:
///     - Creates a plain object from a database model for use in business logic.
///     - Restores enums from their raw values.
///     - Reconstructs `URL` properties from their `String` representations.
///     - Utilizes translators for nested plain objects to recreate them from their database counterparts.
///   - Manages array and optional properties, ensuring correct conversion logic.
///
///   Example of a generated `Translator`:
///   ```swift
///   public final class Translator: SDAO.Translator {
///
///       // MARK: - Aliases
///
///       public typealias PlainModel = MyPlainObject
///       public typealias DatabaseModel = MyPlainObject.DatabaseModel
///
///       // MARK: - Properties
///
///       private lazy var storage = RealmStorage<DatabaseModel>(configuration: self.configuration)
///
///       private let configuration: RealmConfiguration
///
///       // MARK: - Initializers
///
///       public init(configuration: RealmConfiguration) {
///           self.configuration = configuration
///       }
///
///       public func translate(model: DatabaseModel) throws -> PlainModel {
///           MyPlainObject(
///               id: model.id,
///               name: model.name,
///               tags: Array(model.tags),
///               age: model.age,
///               nickname: model.nickname,
///               scores: Array(model.scores),
///               details: try DetailsPlainObject.Translator(configuration: configuration).translate(model: model.details.unsafelyUnwrapped),
///               additionalDetails: try DetailsPlainObject.Translator(configuration: configuration).translate(models: Array(model.additionalDetails))
///           )
///       }
///
///       public func translate(plain: PlainModel) throws -> DatabaseModel {
///           let model = try storage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
///           try translate(from: plain, to: model)
///           return model
///       }
///
///       public func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
///           databaseModel.id = plain.id
///           databaseModel.name = plain.name
///           databaseModel.tags.removeAll()
///           databaseModel.tags.append(objectsIn: plain.tags)
///           databaseModel.age = plain.age
///           databaseModel.nickname = plain.nickname
///           databaseModel.scores.removeAll()
///           databaseModel.scores.append(objectsIn: plain.scores)
///           databaseModel.details = try DetailsPlainObject.Translator(configuration: configuration).translate(plain: plain.details)
///           databaseModel.additionalDetails.removeAll()
///           databaseModel.additionalDetails.append(objectsIn: try DetailsPlainObject.Translator(configuration: configuration).translate(plains: plain.additionalDetails))
///       }
///   }
///   ```
///
/// #### Attributes:
/// - `@attached(member, names: arbitrary)`: Adds additional declarations to the struct.
/// - `@attached(extension, conformances: Plain)`: Ensures the struct conforms to `SDAO.Plain`.
@attached(member, names: arbitrary)
@attached(extension, conformances: Plain)
public macro DAOPlain() = #externalMacro(module: "SwiftMacrosKitMacros", type: "DAOPlainMacro")

