//
//  ContentViewModel.swift
//  StatusBarJobTimer
//
//  Created by Михаил Серегин on 11.02.2023.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    @Published var state = Status.stop
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    @Published var remaining: TimeInterval = 0
    
    @Published var workTime = 0
    @Published var pauseTime = 0
    
    var settings = TimerSettings()
    
    let popupPublisher = PassthroughSubject<PopupType, Never>()
    
    private var disposables = Set<AnyCancellable>()
    private var notificationService = LocalNotificationService()
    private let eventStorage = EventStorage()
    
    init() {
        self.setRemainingTime()
        workTime = settings.workTime
        pauseTime = settings.pauseTime
        notificationService.requestAuth()
        bind()
        Task {
            do {
                try await eventStorage.checkAuthorization()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func start() {
        Task { @MainActor in
            let date = Date()
            if let event = await eventStorage.isStartEventItTimeInterval(interval: .init(start: date, duration: remaining)) {
                let diff = event.startDate.timeIntervalSinceReferenceDate - date.timeIntervalSinceReferenceDate
                if diff > 0 && remaining > diff {
                    popupPublisher.send(.pause("Скоро встреча!\n\(event.title)"))
                    remaining = diff
                } else {
                    popupPublisher.send(.pause("Встреча!\n\(event.title)"))
                }
            }
            notificationService.addNotification(.pauseAt(remaining))
            state = .play
        }
    }
    
    func pause() {
        notificationService.clearQueue()
        state = .pause
        notificationService.addNotification(.resumeAt(TimeInterval(settings.pauseTime * 60)))
    }

    func stop() {
        state = .stop
        self.setRemainingTime()
        notificationService.clearQueue()
    }
    
    func bind() {
        timer.sink { [weak self] _ in
            guard let self, self.state == .play, self.remaining > 0 else { return }
            self.remaining -= 1
            if self.remaining == 0 {
                self.state = .stop
                self.popupPublisher.send(.pause("Пора отдохнуть"))
                self.setRemainingTime()
                self.notificationService.addNotification(.resumeAt(TimeInterval(self.settings.pauseTime * 60)))
            }
        }
        .store(in: &disposables)
        
        $workTime.combineLatest($pauseTime)
            .dropFirst()
            .sink { (wt, pt) in
                TimerSettings.save(workTime: wt, pauseTime: pt)
                self.settings = .init()
                self.setRemainingTime()
                self.workTime = wt
                self.pauseTime = pt
            }
            .store(in: &disposables)
    }
    
    func setRemainingTime() {
        remaining = TimeInterval(settings.workTime * 60)
    }
}

struct TimerSettings {
    let workTime: Int
    let pauseTime: Int
    
    init() {
        workTime = Self.getWorkTime()
        pauseTime = Self.getPauseTime()
    }
    
    static func save(workTime: Int, pauseTime: Int) {
        UserDefaults.standard.set(workTime, forKey: "workTime")
        UserDefaults.standard.set(pauseTime, forKey: "pauseTime")
    }
    
    static func getWorkTime() -> Int {
        UserDefaults.standard.integer(forKey: "workTime")
    }
    
    static func getPauseTime() -> Int {
        UserDefaults.standard.integer(forKey: "pauseTime")
    }
}
