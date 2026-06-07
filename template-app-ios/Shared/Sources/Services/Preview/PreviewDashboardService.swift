#if DEBUG

import Combine
import Foundation

final class PreviewDashboardService: DashboardServiceType, @unchecked Sendable {

    var dashboard: DashboardModel? = DashboardModel.mockData

    var dashboardPublisher: AnyPublisher<DashboardModel?, Never> {
        return Just(self.dashboard).eraseToAnyPublisher()
    }

    func refresh() async throws {
        // no-op
    }

    func clearState() {
        self.dashboard = nil
    }

}

#endif
