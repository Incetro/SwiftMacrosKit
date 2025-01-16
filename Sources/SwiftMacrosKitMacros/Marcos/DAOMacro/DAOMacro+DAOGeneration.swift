//
//  DAOMacro+DAOGeneration.swift
//  SwiftMacrosKit
//
//  Created by Gleb Kovalenko on 14.01.2025.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics
import Foundation

// MARK: - DAOMacro+DAOGeneration

extension DAOMacro {
    
    static func makeDAOAlias(plainName: String) -> DeclSyntax {
        let daoAlias = """
        // MARK: - DAO
        
        public typealias DAO = SDAO.DAO<RealmStorage<\(plainName).DatabaseModel>, \(plainName).Translator>
        """
        return DeclSyntax(stringLiteral: daoAlias)
    }
}
