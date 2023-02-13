//
//  Date+Extension.swift
//  Simple Focus Timer
//
//  Created by Михаил Серегин on 13.02.2023.
//

import Foundation

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? Date()
    }
}
