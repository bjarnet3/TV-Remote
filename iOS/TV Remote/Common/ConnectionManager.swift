//
//  Network.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 06/10/2022.
//  Copyright © 2022 Digital Mood. All rights reserved.
//

import Foundation
import NetworkExtension

class ConnectionManager {

    static let shared = ConnectionManager()
    private init () {}

    private var monitorNetwork = NWPathMonitor(requiredInterfaceType: .wifi)

    func startNetworkMonitoring(networkType: NWInterface.InterfaceType) {
        monitorNetwork = NWPathMonitor(requiredInterfaceType: networkType)
        // let status = monitorWiFi.currentPath.status
        monitorNetwork.pathUpdateHandler = { path in
            /// This closure is called every time the connection status changes
            DispatchQueue.main.async {
                switch path.status {
                case .satisfied:
                    print("PathMonitor WiFi satisfied, interface: \(path.availableInterfaces) gateways: \(path.gateways)")
                default:
                    print("PathMonitor WiFi not satisfied: \(path.unsatisfiedReason)")
                }
            }
        }
        monitorNetwork.start(queue: DispatchQueue(label: "monitorWiFi"))
    }

    func cancelNetworkMonitoring() {
        monitorNetwork.cancel()
    }

    func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability()
            let networkStatus = reachability.connection

            switch networkStatus {
            case .unavailable:
                return false
            case .wifi:
                return true
            case .cellular:
                return true
            }
        }
        catch {
            return false
        }
    }
}
