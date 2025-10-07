import Foundation
import Combine

import MustacheServices

protocol DashboardViewModelType {

    var userPublisher: AnyPublisher<UserModel?, Never> { get }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> { get }

    func refresh() async throws
}

class DashboardViewModel: DashboardViewModelType {

    // MARK: Variables
    
    var userPublisher: AnyPublisher<UserModel?, Never> {
        return self.userService.userPublisher
    }

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return self.dashboardService.dashboardPublisher
    }
    
    // MARK: Variables

    @Injected
    private var userService: UserServiceType

    @Injected
    private var dashboardService: DashboardServiceType
    
    // MARK: State variables

    // MARK: Init
    
    init() {
        self.configure()
    }
    
    // MARK: Configure

    func configure() { Task {
        try await self.refresh()
    }}
    
    // MARK: functions

    func refresh() async throws {
//        let _ = try await (self.userService.refresh(), self.dashboardService.refresh())
        try await self.dashboardService.refresh()
    }

    deinit {
        debugPrint("deinit \(self)")
    }

}
