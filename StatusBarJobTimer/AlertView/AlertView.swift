//
//  AlertView.swift
//  Simple Focus Timer
//
//  Created by Михаил Серегин on 13.02.2023.
//

import SwiftUI

enum PopupType {
    case pause(String), resume
}

struct AlertView: View {
    let popup: PopupType
    
    var body: some View {
        VStack {
            content
        }
        .padding()
    }
    
    @ViewBuilder
    var content: some View {
        switch popup {
        case .pause(let text):
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.largeTitle)
                .padding(.bottom, 16)
                .foregroundColor(.green)
            Text(text)
                .font(.title)
        case .resume:
            Image(systemName: "alarm.waves.left.and.right.fill")
                .font(.largeTitle)
                .padding(.bottom, 16)
                .foregroundColor(.red)
            Text("Пора работать")
                .font(.title)
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(popup: .pause("Пора отдохнуть"))
            .padding()
    }
}
