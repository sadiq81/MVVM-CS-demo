import Combine
import Foundation

import MustacheServices

protocol DashboardViewModelType: Sendable {

    var userPublisher: AnyPublisher<UserModel?, Never> { get }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }

    func refresh() async throws
}

@MainActor
final class DashboardViewModel: @preconcurrency DashboardViewModelType {

    // MARK: Variables
    
    var userPublisher: AnyPublisher<UserModel?, Never> {
        return self.userService.userPublisher
    }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.dashboardService.dashboardPublisher
    }
    
    // MARK: Variables

    @Injected(\.userService)
    private var userService: any UserServiceType

    @Injected(\.dashboardService)
    private var dashboardService: any DashboardServiceType
    
    // MARK: State variables

    // MARK: Init
    
    init() {
        self.configure()
    }
    
    // MARK: Configure

    func configure() {
        Task { try await self.refresh() }
    }
    
    // MARK: functions

    func refresh() async throws {
        let _ = try await (self.userService.refresh(), self.dashboardService.refresh())
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}

// MARK: - Preview

#if DEBUG

final class PreviewDashboardViewModel: DashboardViewModelType, @unchecked Sendable {

    // MARK: Variables

    var userPublisher: AnyPublisher<UserModel?, Never> {
        return Just(UserModel.mockData).eraseToAnyPublisher()
    }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return Just(DashboardModel.mockData).eraseToAnyPublisher()
    }

    // MARK: functions

    func refresh() async throws {}

}

#endif
