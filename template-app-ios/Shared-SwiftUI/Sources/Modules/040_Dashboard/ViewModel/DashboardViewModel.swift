
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: Services

    @Injected(\.userService)
    private var userService: any UserServiceType
    
    @Injected(\.dashboardService)
    private var dashboardService: any DashboardServiceType

    // MARK: State

    @Published var user: UserModel?
    @Published var dashboard: DashboardModel?
    @Published var isLoading = false

    // MARK: Init

    init() {
        self.configure()
    }

    // MARK: Configure

    private func configure() {
        self.userService.userPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$user)

        self.dashboardService.dashboardPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$dashboard)

        Task { await self.refresh() }
    }

    // MARK: Functions

    func refresh() async {
        self.isLoading = true
        defer { self.isLoading = false }
        let _ = try? await (self.userService.refresh(), self.dashboardService.refresh())
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
