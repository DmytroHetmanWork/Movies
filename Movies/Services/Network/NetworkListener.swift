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
    private var retryQueue: [() -> Void] = []
    private var pollingTimer: Timer?
    
    var isReachable: Bool = false
    
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
                self?.handleConnectionLoss()
            case .unknown:
                break
            }
        }
        
        startPolling()
    }
    
    private func handleConnectionLoss() {
        guard isReachable else { return }
        
        isReachable = false
        connectionLostClosure?()
        print("Internet connection lost.")
    }
    
    private func handleReconnection() {
        guard !isReachable else { return }
        
        isReachable = true
        connectionBackClosure?()
        print("Internet reconnected. Executing retry queue.")
        
        retryQueue.forEach { $0() }
        retryQueue.removeAll()
    }
    
    func addRetryableTask(_ task: @escaping () -> Void) {
        retryQueue.append(task)
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

