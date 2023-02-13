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
    private var alertPopover: NSPopover?
    
    let viewModel = ContentViewModel()
    private var disposables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.prohibited)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        bind()
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
                viewModel.setRemainingTime()
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func bind() {
        viewModel.popupPublisher.sink { type in
            self.alertPopover = NSPopover()
            self.alertPopover?.contentSize = NSSize(width: 250, height: 250)
            self.alertPopover?.behavior = .transient
            self.alertPopover?.contentViewController = NSHostingController(rootView: AlertView(popup: type))
            
            if let button = self.statusItem.button {
                if self.alertPopover?.isShown ?? false {
                    self.popover.performClose(nil)
                } else {
                    self.alertPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }.store(in: &disposables)
    }
}
