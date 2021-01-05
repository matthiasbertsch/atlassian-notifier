//
//  AppDelegate.swift
//  Atlassian Notifier
//
//  Created by Matthias Bertsch.
//  Copyright © 2020 Matthias Bertsch. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // APPLICATION
    
    let status = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    @available(macOS, deprecated: 10.11)
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = status.button {
            button.image = NSImage(named:NSImage.Name("ico"))
        }
        
        menu()
        schedule()
    }

    func applicationWillTerminate(_ notification: Notification) {
        
    }
    
    // MENU
    
    let start = Start()
    let path : CFURL =  CFURLCreateWithString(nil, "file:///Applications/Atlassian%20Notifier.app/" as CFString, nil);
    
    @available(macOS, deprecated: 10.11)
    func menu() {
        let launch = NSMenuItem(title: "Start automatically...", action: #selector(toggle(_:)), keyEquivalent: "")
        launch.state = (start.get(path) != nil) ? .on : .off
        
        let separator = NSMenuItem.separator()
        
        let quit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let menu = NSMenu()
        menu.addItem(launch)
        menu.addItem(separator)
        menu.addItem(quit)

        self.status.menu = menu
    }
    
    @available(macOS, deprecated: 10.11)
    @IBAction func toggle(_ sender: NSMenuItem) {
        if sender.state == .on {
            if self.start.remove(path) {
                sender.state = .off
            }
        } else {
            if self.start.add(path) {
                sender.state = .on
            }
        }
    }
    
    // REQUEST
    
    var timer = Timer()
    
    var jira = false
    var confluence = false
    var bitbucket = false
    
    func schedule() {
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }

    @objc func update() {
        self.bitbucket = self.query(url: "http://localhost:7990/bitbucket", application: "Bitbucket", variable: self.bitbucket)
        self.confluence = self.query(url: "http://localhost:1990/confluence", application: "Confluence", variable: self.confluence)
        self.jira = self.query(url: "http://localhost:2990/jira", application: "Jira", variable: self.jira)
    }
    
    func query(url: String, application: String, variable: Bool) -> Bool {
        let text = request(url: URL(string: url)!)
        let result = check(text: text, title: application + "</title>")
        
        if(result && !variable) {
            if (dialog(image: application, title: application + " is up and running!", content: "Would you like to visit it now?")) {
                NSWorkspace.shared.open(URL(string: url)!)
            }
        }
            
        return result
    }
        
    func request(url: URL) -> Data? {
        var text: Data?
        
        let semaphore = DispatchSemaphore(value: 0)

        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            defer { semaphore.signal() }

            if let _ = error {
                return
            }

            text = data
        })

        task.resume()

        _ = semaphore.wait(timeout: .distantFuture)
        
        return text
    }
    
    func check(text: Data?, title: String) -> Bool {
        if let data = text, let text = String(data: data, encoding: .utf8) {
            return text.contains(title)
        }
        
        return false
    }
    
    func dialog(image: String, title: String, content: String) -> Bool {
        let alert = NSAlert()
        
        alert.icon = NSImage(named:NSImage.Name(image))
        alert.messageText = title
        alert.informativeText = content
        
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        return alert.runModal() == .alertFirstButtonReturn
    }
    
}
