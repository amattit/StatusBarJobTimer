//
//  EventStorage.swift
//  Simple Focus Timer
//
//  Created by Михаил Серегин on 13.02.2023.
//

import Foundation
import EventKit

actor EventStorage {
    private let store: EKEventStore
    private let queue: DispatchQueue = .init(label: "Events", qos: .background)
    private let main: DispatchQueue = .main
    private var events: [EKEvent] = []
    
    init() {
        self.store = .init()
    }
    
    private func requestAuthorization() async throws {
        try await store.requestAccess(to: .event)
    }
    
    private func reload() {
        
            let calendars = self.store.calendars(for: .event)
            let predicate = self.store.predicateForEvents(withStart: Date.startOfDay, end: Date.endOfDay, calendars: calendars)
            self.events = self.store.events(matching: predicate)
        
    }
    
    func isStartEventItTimeInterval(interval: DateInterval) -> Event? {
        let calendars = self.store.calendars(for: .event)
        let predicate = self.store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: calendars)
        let events = self.store.events(matching: predicate)
            .filter { $0.isAllDay == false }
            .sorted { $0.startDate < $1.startDate }
        guard let event = events.first, !event.isAllDay else { return nil }
        return Event(title: event.title, startDate: event.startDate)
    }
    
    func checkAuthorization() async throws {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            try await requestAuthorization()
        case .denied:
            try await requestAuthorization()
        default:
            break
        }
    }
}

struct Event {
    let title: String
    let startDate: Date
}
