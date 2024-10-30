//
//  WithLocalizationUpdaterMacro.swift
//
//
//  Created by Gleb Kovalenko on 30.10.2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftDiagnostics
import SwiftSyntaxMacros

// MARK: - WithLocalizationUpdaterMacro

/// The `WithLocalizationUpdaterMacro` macro automatically injects an `ObservedObject`
/// for managing localization updates within SwiftUI views. When the locale changes,
/// this object triggers a view update, allowing for dynamic localization.
///
/// This macro is intended for use within SwiftUI `View` structs where localization
/// changes need to propagate automatically to update the view content.
public struct WithLocalizationUpdaterMacro: MemberMacro {

    // MARK: - Expansion Method

    /// Expands the macro to add an `ObservedObject` property that observes locale changes.
    ///
    /// - Parameters:
    ///   - attribute: The `AttributeSyntax` node where the macro is applied.
    ///   - declaration: The `DeclGroupSyntax` to which the macro is attached.
    ///   - context: The context in which the macro expansion occurs.
    ///
    /// - Returns: An array of `DeclSyntax` containing the `ObservedObject` declaration.
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Generates the name of the updater property
        let updaterName = Constants.WithLocalizationUpdaterMacro.updaterName
        let observedObjectDeclaration = """
        @ObservedObject private var \(updaterName.lowercaseFirstLetter()) = \(updaterName)()
        """
        
        // Return the generated ObservedObject declaration
        return [DeclSyntax(stringLiteral: observedObjectDeclaration)]
    }
}
