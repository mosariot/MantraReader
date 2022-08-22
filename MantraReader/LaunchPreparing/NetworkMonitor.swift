//
//  NetworkMonitor.swift
//  MantraReader
//
//  Created by Alex Vorobiev on 21.01.2021.
//

import Network

final class NetworkMonitor {
    var isReachable: Bool { status == .satisfied }
    private let monitor = NWPathMonitor()
    private var status: NWPath.Status = .requiresConnection
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.status = path.status
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
