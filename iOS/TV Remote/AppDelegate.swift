//
//  AppDelegate.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 21.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Shortcut Action (1)
    // ---------------------
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }

    // Shortcut Action (2)
    // ---------------------
    func handleShortcut(shortcutItem: UIApplicationShortcutItem ) -> Bool {

        // Init remote
        let ip = UserDefaults.standard.string(forKey: "ip") ?? "192.168.50.7"
        let pin = UserDefaults.standard.string(forKey: "pin") ?? "0000"

        let remote = Remote(name: "Sony Remote", type: .smart, ip: ip, pin: pin)
        let remoteHandler = RemoteHandler(remote: remote)
        
        func shortCutCase() -> Bool {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()
            window?.rootViewController = vc

            return true
        }
        
        switch shortcutItem.type {
        case "no.digitalmood.TV-Remote.iOS.power" :

            remoteHandler.send(command: .power)
            return shortCutCase()

        default :

            remoteHandler.send(command: .mute)
            return shortCutCase()
        }

    }
    
    
}

