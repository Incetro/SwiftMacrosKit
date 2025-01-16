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
    
    static func generateModelToPlainMapping(properties: [PropertyPlain]) -> String {
        properties.map { property in
            let modelValuePath = "model.\(property.name)\(property.isShouldUseRealmProperty ? ".value" : "")"
            let translateString = property.translate(with: .fromModelToPlain, valuePath: modelValuePath)
            return "\(property.name): \(translateString)"
        }.joined(separator: ",\n")
    }
    
    static func generatePlainToModelMapping(properties: [PropertyPlain]) -> String {
        properties.map { property in
            let plainValuePath = "plain.\(property.name)"
            let databaseValuePath = "databaseModel.\(property.name)\(property.isShouldUseRealmProperty ? ".value" : "")"
            let translateString = property.translate(with: .fromPlainToModel, valuePath: plainValuePath)
            if property.isArray {
                return "databaseModel.\(property.name).removeAll()\n" + "\(databaseValuePath).append(objectsIn: \(translateString))"
            } else {
                return "\(databaseValuePath) = \(translateString)"
            }
        }.joined(separator: "\n")
    }
}
