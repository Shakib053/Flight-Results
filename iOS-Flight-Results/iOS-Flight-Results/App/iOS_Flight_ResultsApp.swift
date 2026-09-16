//
//  iOS_Flight_ResultsApp.swift
//  iOS-Flight-Results
//
//  Created by Kazi Tanjim Shakib on 15/9/26.
//

import SwiftUI

@main
struct iOS_Flight_ResultsApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            coordinator.makeRootView()
        }
    }
}
