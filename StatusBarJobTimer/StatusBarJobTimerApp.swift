//
//  StatusBarJobTimerApp.swift
//  StatusBarJobTimer
//
//  Created by Михаил Серегин on 11.02.2023.
//

import SwiftUI

@main
struct StatusBarJobTimerApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: appDelegate.viewModel)
        }
    }
}

import Combine

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    
    let viewModel = ContentViewModel()
    private var disposables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        if let statusButton = statusItem.button {
            statusButton.title = TimeInterval.formatter.string(from: viewModel.remaining) ?? "00:00"
            statusButton.action = #selector(togglePopover)
            
            viewModel.$remaining.sink { remaining in
                statusButton.title = TimeInterval.formatter.string(from: remaining) ?? "00:00"
            }
            .store(in: &disposables)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 250, height: 250)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView(viewModel: viewModel))
    }
    
    @objc
    func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
}
