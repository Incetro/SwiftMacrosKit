//
//  LocalizationViewUpdater.swift
//
//
//  Created by Gleb Kovalenko on 29.10.2024.
//

import Combine
import SwiftUI

// MARK: - LocalizationViewUpdater

public class LocalizationViewUpdater: ObservableObject {
    
    // MARK: - Properties
    
    /// Cancellable
    private var cancellable: AnyCancellable?
    
    // MARK: - Initializers

    public init() {
        cancellable = NotificationCenter
            .default
            .publisher(
                for: NSLocale.currentLocaleDidChangeNotification
            )
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
    }

    deinit {
        cancellable?.cancel()
    }
}
