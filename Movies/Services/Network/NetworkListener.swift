//
//  NetworkListener.swift
//  Movies
//
//  Created by Dmytro Hetman on 27.01.2025.
//

import Alamofire

final class NetworkListener {
    
    static let shared = NetworkListener()
    
    private var connectionBackClosure: (() -> Void)?
    private var connectionLostClosure: (() -> Void)?
    private var pollingTimer: Timer?
    
    var isReachable: Bool = false /// Flag to track internet connectivity
    
    private let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")
    
    private init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        reachabilityManager?.startListening { [weak self] status in
            switch status {
            case .reachable(.ethernetOrWiFi), .reachable(.cellular):
                self?.handleReconnection()
            case .notReachable:
                // This may not always trigger consistently
                self?.handleConnectionLoss()
            case .unknown:
                break
            }
        }
        
        // Start polling in case `.notReachable` doesn't trigger
        startPolling()
    }
    
    private func handleConnectionLoss() {
        // Stop polling if already handled
        guard isReachable else { return }
        
        isReachable = false
        connectionLostClosure?()
        print("Internet connection lost.")
    }
    
    private func handleReconnection() {
        guard !isReachable else { return } // Only trigger if it was previously unreachable
        
        isReachable = true
        connectionBackClosure?()
        print("Internet reconnected.")
    }
    
    func setConnectionLostClosure(_ closure: (() -> Void)?) {
        connectionLostClosure = closure
    }
    
    func setConnectionBackClosure(_ closure: (() -> Void)?) {
        connectionBackClosure = closure
    }
    
    private func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkConnectionManually()
        }
    }
    
    private func checkConnectionManually() {
        reachabilityManager?.startListening(onQueue: DispatchQueue.main) { [weak self] status in
            switch status {
            case .reachable:
                self?.handleReconnection()
            case .notReachable:
                self?.handleConnectionLoss()
            default:
                break
            }
        }
    }
    
    deinit {
        pollingTimer?.invalidate()
        reachabilityManager?.stopListening()
    }
}
