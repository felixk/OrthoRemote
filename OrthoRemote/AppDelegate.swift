//
//  AppDelegate.swift
//  OrthoRemote
//
//  Created by Felix Khazin on 5/4/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var bluetoothManager: BluetoothManager = BluetoothManager()
    
    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application
        
        statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

        if let statusItem = statusItem, let button = statusItem.button {
          button.image = NSImage(named:NSImage.Name("orthoremote"))
        }
        
        constructMenu()

    }
    
    @objc func connectToRemote(_ sender: Any?) {
        self.bluetoothManager.scan()
    }

    func constructMenu() {
      let menu = NSMenu()

      menu.addItem(NSMenuItem(title: "Connect to remote", action: #selector(AppDelegate.connectToRemote(_:)), keyEquivalent: "C"))
      menu.addItem(NSMenuItem.separator())
      menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        if let statusItem = statusItem {
            statusItem.menu = menu
        }
    }


    func applicationWillTerminate(_: Notification) {
        self.bluetoothManager.disconnectFromDevice()
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        return true
    }
}
