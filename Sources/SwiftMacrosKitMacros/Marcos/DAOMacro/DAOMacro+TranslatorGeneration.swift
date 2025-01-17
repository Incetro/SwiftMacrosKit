//
//  DAOPlainMacro+TranslatorGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOPlainMacro+TranslatorGeneration

extension DAOPlainMacro {
    
    /// This function generates the `Translator` class for a given plain object.
    /// The `Translator` class is responsible for translating between the `PlainModel`
    /// and `DatabaseModel` and managing their persistence in the database.
    ///
    /// The generated translator includes:
    /// - Translation methods (`translate` and `translate(from:to:)`) for both directions.
    /// - A `RealmStorage` instance for database management.
    ///
    /// - Parameters:
    ///   - plainName: The name of the plain object.
    ///   - properties: A list of properties to include in the translation logic.
    /// - Returns: A `DeclSyntax` object representing the translator class.
    static func makeTranslator(plainName: String, properties: [PropertyPlain]) -> DeclSyntax {
        let translatorClass = """
        // MARK: - Translator
        
        public final class Translator: SDAO.Translator {
        
            // MARK: - Aliases
        
            public typealias PlainModel = \(plainName)
            public typealias DatabaseModel = \(plainName).DatabaseModel
        
            /// Plain storage
            private lazy var storage = RealmStorage<DatabaseModel>(configuration: self.configuration)
        
            /// RealmConfiguration instance
            private let configuration: RealmConfiguration
        
            // MARK: - Initializers
        
            /// Default initializer
            /// - Parameters:
            ///   - configuration: current realm db config
            public init(configuration: RealmConfiguration) {
                self.configuration = configuration
            }
        
            public func translate(model: DatabaseModel) throws -> PlainModel {
                \(plainName)(
                    \(generateModelToPlainMapping(properties: properties))
                )
            }
        
            public func translate(plain: PlainModel) throws -> DatabaseModel {
                let model = try storage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
                try translate(from: plain, to: model)
                return model
            }
        
            public func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
                if databaseModel.uniqueId.isEmpty {
                    databaseModel.uniqueId = plain.uniqueId.rawValue
                }
                \(generatePlainToModelMapping(properties: properties))
            }
        }
        """
        return DeclSyntax(stringLiteral: translatorClass)
    }
    
    /// Generates the mapping logic for translating a `DatabaseModel`
    /// into a `PlainModel`.
    ///
    /// Each property in the database model is mapped to its corresponding property
    /// in the plain model. Special handling is applied for enums, arrays, and optional properties.
    ///
    /// - Parameter properties: The list of properties to include in the mapping.
    /// - Returns: A string representing the mapping logic.
    static func generateModelToPlainMapping(properties: [PropertyPlain]) -> String {
        properties.map { property in
            let modelValuePath = "model.\(property.modelName)\(property.isShouldUseRealmProperty ? ".value" : "")"
            let translateString = property.translate(with: .fromModelToPlain, valuePath: modelValuePath)
            return "\(property.name): \(translateString)"
        }.joined(separator: ",\n")
    }
    
    /// Generates the mapping logic for translating a `PlainModel`
    /// into a `DatabaseModel`.
    ///
    /// Each property in the plain model is mapped to its corresponding property
    /// in the database model. Special handling is applied for enums, arrays, and optional properties.
    ///
    /// - Parameter properties: The list of properties to include in the mapping.
    /// - Returns: A string representing the mapping logic.
    static func generatePlainToModelMapping(properties: [PropertyPlain]) -> String {
        properties.map { property in
            let plainValuePath = "plain.\(property.name)"
            let databaseValuePath = "databaseModel.\(property.modelName)\(property.isShouldUseRealmProperty ? ".value" : "")"
            let translateString = property.translate(with: .fromPlainToModel, valuePath: plainValuePath)
            if property.isArray {
                return "databaseModel.\(property.modelName).removeAll()\n" + "\(databaseValuePath).append(objectsIn: \(translateString))"
            } else {
                return "\(databaseValuePath) = \(translateString)"
            }
        }.joined(separator: "\n")
    }
}
