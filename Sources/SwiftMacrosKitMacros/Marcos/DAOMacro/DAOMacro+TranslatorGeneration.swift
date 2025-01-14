//
//  DAOMacro+TranslatorGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro+TranslatorGeneration

extension DAOMacro {
    
    static func makeTranslator(plainName: String, properties: [PropertyPlain]) -> DeclSyntax {
        let translatorClass = """
        // MARK: - Translator
        
        final class Translator: SDAO.Translator {
        
            // MARK: - Aliases
        
            typealias PlainModel = \(plainName)
            typealias DatabaseModel = \(plainName).DatabaseModel
        
            /// Plain storage
            private lazy var storage = RealmStorage<DatabaseModel>(configuration: self.configuration)
        
            /// RealmConfiguration instance
            private let configuration: RealmConfiguration
        
            // MARK: - Initializers
        
            /// Default initializer
            /// - Parameters:
            ///   - configuration: current realm db config
            init(configuration: RealmConfiguration) {
                self.configuration = configuration
            }
        
            func translate(model: DatabaseModel) throws -> PlainModel {
                \(plainName)(
                    \(generateModelToPlainMapping(properties: properties))
                )
            }
        
            func translate(plain: PlainModel) throws -> DatabaseModel {
                let model = try storage.read(byPrimaryKey: plain.uniqueId.rawValue) ?? DatabaseModel()
                try translate(from: plain, to: model)
                return model
            }
        
            func translate(from plain: PlainModel, to databaseModel: DatabaseModel) throws {
                if databaseModel.uniqueId.isEmpty {
                    databaseModel.uniqueId = plain.uniqueId.rawValue
                }
                \(generatePlainToModelMapping(properties: properties))
            }
        }
        """
        return DeclSyntax(stringLiteral: translatorClass)
    }
    
    static func generateModelToPlainMapping(properties: [PropertyPlain]) -> String {
        properties.map { property in
            makeInitVariableString(
                modelValuePath: "model.\(property.name)\(property.isShouldUseRealmProperty ? ".value" : "")",
                property: property
            )
        }.joined(separator: ",\n")
    }
    
    static func generatePlainToModelMapping(properties: [PropertyPlain]) -> String {
        return ""
    }
}
