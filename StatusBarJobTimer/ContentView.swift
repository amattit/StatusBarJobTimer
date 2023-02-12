//
//  ContentView.swift
//  StatusBarJobTimer
//
//  Created by Михаил Серегин on 11.02.2023.
//

import SwiftUI

enum Status: String {
    case play, pause, stop
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    var body: some View {
        VStack {
            HStack {
                Spacer()
                exitButton
            }
            .padding(.bottom, 8)
            content()
        }
        .frame(width: 250)
        .padding()
    }
    
    @ViewBuilder
    func content() -> some View {
        switch viewModel.state {
        case .play, .pause:
            VStack {
                timerView
                HStack {
                    playPauseView()
                }
            }
        case .stop:
            HStack {
                Stepper("Время работы (в минутах)", value: $viewModel.workTime, step: 15)
                Spacer()
                Text(viewModel.workTime.formatted())
            }
            
            HStack {
                Stepper("Время отдыха (в минутах)", value: $viewModel.pauseTime, step: 15)
                Spacer()
                Text(viewModel.pauseTime.formatted())
            }
            
            playView
        }
    }
    
    @ViewBuilder
    func playPauseView() -> some View {
        if viewModel.state == .play {
            pauseView
            stopView
        } else if viewModel.state == .pause {
            playView
            stopView
        }
    }
    
    var playView: some View {
        Button(action: viewModel.start) {
            Image(systemName: "play")
        }
    }
    
    var pauseView: some View {
        Button(action: viewModel.pause) {
            Image(systemName: "pause")
        }
    }
    
    var stopView: some View {
        Button(action: viewModel.stop) {
            Image(systemName: "stop")
        }
    }
    
    var timerView: some View {
        Text("Осталось: \(remaining)")
    }
    
    var remaining: String {
        TimeInterval.formatter.string(from: viewModel.remaining) ?? "00:00"
    }
    
    var exitButton: some View {
        Button(action: {NSApplication.shared.terminate(nil)}) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        }
        .buttonStyle(.borderless)
    }
}

extension TimeInterval {
    static var formatter: DateComponentsFormatter {
        DateComponentsFormatter()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}

