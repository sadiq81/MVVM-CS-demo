//
//  ClassListModel.swift
//  customerapp
//
//  Created by Daniel Jensen on 16/03/2023.
//

import Foundation

class ClassListModel: Hashable, Codable {

    var id: String
    var classId: String
    var from: Date
    var to: Date
    var title: String?
    var subtitle: String?
    var address: ClassAddress?
    var locationName: String?
    var instructor: ClassInstructor?
    var latestAttendanceText: String?
    var cancellationNotAllowedText: String?
    var cancellationAllowedUntil: Date
    var attendanceAllowedUntil: Date
    var attendees: Int
    var maxAttendees: Int
    var maxOnWaitingList: Int?
    var isAttending: Bool
    var isOnWaitingList: Bool
    var waitingListNumber: Int?
    var waitingListAttendees: Int
    var isCancelled: Bool

    init(with response: ClassListResponse) {
        self.id = response.id
        self.classId = response.classId
        self.from = response.from
        self.to = response.to
        self.title = response.title
        self.subtitle = response.subtitle
        self.address = response.address
        self.locationName = response.locationName
        self.instructor = response.instructor
        self.latestAttendanceText = response.latestAttendanceText
        self.cancellationNotAllowedText = response.cancellationNotAllowedText
        self.cancellationAllowedUntil = response.cancellationAllowedUntil
        self.attendanceAllowedUntil = response.attendanceAllowedUntil
        self.attendees = response.attendees
        self.maxAttendees = response.maxAttendees
        self.maxOnWaitingList = response.maxOnWaitingList
        self.isAttending = response.isAttending
        self.isOnWaitingList = response.isOnWaitingList
        self.waitingListNumber = response.waitingListNumber
        self.waitingListAttendees = response.waitingListAttendees
        self.isCancelled = response.isCancelled
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ClassListModel, rhs: ClassListModel) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }
        if lhs.id != rhs.id { return false }
        return true
    }

}
