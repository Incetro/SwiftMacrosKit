//
//  MarcoError.swift
//
//
//  Created by Gleb Kovalenko on 30.10.2024.
//

// MARK: - MacroError

public struct MacroError: Error, CustomStringConvertible {
    
    // MARK: - Properties
    
    /// Error message
    public let message: String
    
    /// Error description
    public var description: String {
        message
    }
}
