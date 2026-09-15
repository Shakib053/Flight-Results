import Foundation

/// A local promotional card whose destination is opened by the Coordinator.
struct Promotion: Identifiable, Equatable {
    let id: String
    let imageName: String
    let title: String
    let url: URL
}
