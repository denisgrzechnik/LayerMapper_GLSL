//
//  ShaderSyncService.swift
//  LM_GLSL
//
//  MultipeerConnectivity service for real-time shader synchronization.
//  This app acts as a SOURCE, broadcasting shaders to LayerMapper MApp (RECEIVER).
//
//  Created: January 2026
//

import Foundation
import MultipeerConnectivity
import Combine
import UIKit

// MARK: - ShaderSyncService

/// Main service for shader synchronization using MultipeerConnectivity
/// GLSL App is always a SOURCE - it broadcasts shaders to receivers
@MainActor
class ShaderSyncService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAdvertising = false
    @Published var isConnected = false
    @Published var connectedReceivers: [MCPeerID] = []
    @Published var connectionStatus: String = "Nie połączono"
    
    /// Connected receiver states
    @Published var receiverStates: [String: ReceiverState] = [:]
    
    // MARK: - Private Properties
    
    private let serviceType = ShaderSyncProtocol.serviceType
    private let myPeerID: MCPeerID
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Device name used as source identifier
    private let deviceName: String
    
    /// Current shader being broadcast
    private var currentShader: ShaderBroadcast?
    private var currentThumbnail: UIImage?
    
    /// Timers
    private var parameterUpdateTimer: Timer?
    private var heartbeatTimer: Timer?
    private var fullBroadcastTimer: Timer?
    
    /// Parameter values to broadcast
    private var pendingParameterValues: [String: Float] = [:]
    private var currentTime: Double = 0
    private var currentBeat: Double?
    
    // MARK: - Initialization
    
    override init() {
        // Use device name as source identifier
        self.deviceName = UIDevice.current.name
        self.myPeerID = MCPeerID(displayName: "\(deviceName)-GLSL")
        
        super.init()
        
        setupSession()
        
        print("📡 ShaderSyncService initialized as SOURCE (device: \(deviceName))")
    }
    
    deinit {
        // Use synchronous cleanup for deinit
        advertiser?.stopAdvertisingPeer()
        session?.disconnect()
        parameterUpdateTimer?.invalidate()
        heartbeatTimer?.invalidate()
        fullBroadcastTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupSession() {
        session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
    }
    
    // MARK: - Start / Stop
    
    func start() {
        guard !isAdvertising else { return }
        
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: [
                "role": ShaderSyncRole.source.rawValue,
                "version": ShaderSyncProtocol.version,
                "deviceName": deviceName
            ],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        isAdvertising = true
        connectionStatus = "Rozgłaszam..."
        
        startHeartbeat()
        startFullBroadcastTimer()
        
        print("📡 ShaderSync: Started advertising as '\(deviceName)'")
    }
    
    func stop() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        session.disconnect()
        
        stopTimers()
        
        isAdvertising = false
        isConnected = false
        connectedReceivers = []
        connectionStatus = "Nie połączono"
        
        print("📡 ShaderSync: Stopped")
    }
    
    // MARK: - Shader Broadcasting
    
    /// Broadcast a new shader to all receivers
    func broadcastShader(
        shaderId: UUID,
        shaderName: String,
        shaderCategory: String,
        fragmentCode: String,
        vertexCode: String? = nil,
        parameters: [SyncShaderParameter] = [],
        thumbnail: UIImage? = nil
    ) {
        let broadcast = ShaderBroadcast(
            deviceName: deviceName,
            shaderId: shaderId,
            shaderName: shaderName,
            shaderCategory: shaderCategory,
            fragmentCode: fragmentCode,
            vertexCode: vertexCode,
            parameters: parameters,
            bpm: nil,  // TODO: Get from Ableton Link if available
            beat: currentBeat,
            time: currentTime,
            thumbnailHash: thumbnail != nil ? UUID().uuidString : nil
        )
        
        currentShader = broadcast
        currentThumbnail = thumbnail
        
        sendMessage(type: .shaderBroadcast, payload: broadcast)
        
        // Send thumbnail if available
        if let thumbnail = thumbnail {
            let thumbData = ShaderThumbnail(
                deviceName: deviceName,
                shaderId: shaderId,
                image: thumbnail
            )
            sendMessage(type: .shaderThumbnail, payload: thumbData)
        }
        
        print("📡 ShaderSync: Broadcast shader '\(shaderName)' to \(connectedReceivers.count) receivers")
    }
    
    /// Update parameter values (called frequently during animation)
    func updateParameters(_ values: [String: Float], time: Double, beat: Double? = nil) {
        pendingParameterValues = values
        currentTime = time
        currentBeat = beat
    }
    
    /// Start parameter streaming (called when shader starts)
    func startParameterStreaming() {
        parameterUpdateTimer?.invalidate()
        parameterUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / ShaderSyncProtocol.parameterUpdateRate, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendPendingParameterUpdate()
            }
        }
    }
    
    /// Stop parameter streaming
    func stopParameterStreaming() {
        parameterUpdateTimer?.invalidate()
        parameterUpdateTimer = nil
    }
    
    // MARK: - Private Methods
    
    private func sendPendingParameterUpdate() {
        guard isConnected,
              let shader = currentShader,
              !pendingParameterValues.isEmpty else { return }
        
        let update = ParameterUpdate(
            deviceName: deviceName,
            shaderId: shader.shaderId,
            parameterValues: pendingParameterValues,
            time: currentTime,
            beat: currentBeat
        )
        
        // Debug log every 60 frames (about 2 seconds at 30fps)
        if Int(currentTime * 30) % 60 == 0 {
            print("📤 Sync sending params: \(pendingParameterValues) time=\(String(format: "%.2f", currentTime))")
        }
        
        sendMessage(type: .parameterUpdate, payload: update, reliable: false)
    }
    
    private func sendMessage<T: Codable>(type: ShaderSyncMessageType, payload: T, reliable: Bool = true) {
        guard !connectedReceivers.isEmpty else { return }
        
        let message = ShaderSyncMessage(
            type: type,
            payload: payload,
            senderId: deviceName,
            senderName: myPeerID.displayName,
            senderRole: .source
        )
        
        guard let data = message.encoded() else {
            print("❌ ShaderSync: Failed to encode message")
            return
        }
        
        do {
            try session.send(data, toPeers: connectedReceivers, with: reliable ? .reliable : .unreliable)
        } catch {
            print("❌ ShaderSync: Failed to send message: \(error)")
        }
    }
    
    // MARK: - Timers
    
    private func startHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: ShaderSyncProtocol.heartbeatInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendHeartbeat()
            }
        }
    }
    
    private func startFullBroadcastTimer() {
        fullBroadcastTimer?.invalidate()
        fullBroadcastTimer = Timer.scheduledTimer(withTimeInterval: ShaderSyncProtocol.fullBroadcastInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sendFullBroadcast()
            }
        }
    }
    
    private func stopTimers() {
        parameterUpdateTimer?.invalidate()
        parameterUpdateTimer = nil
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
        fullBroadcastTimer?.invalidate()
        fullBroadcastTimer = nil
    }
    
    private func sendHeartbeat() {
        let sourceInfo = ShaderSourceInfo(
            deviceName: deviceName,
            appVersion: "1.0",
            isActive: currentShader != nil
        )
        sendMessage(type: .sourceInfo, payload: sourceInfo)
    }
    
    private func sendFullBroadcast() {
        guard let shader = currentShader else { return }
        
        // Note: ShaderBroadcast is immutable, so we create a new one with updated time
        let newBroadcast = ShaderBroadcast(
            deviceName: shader.deviceName,
            shaderId: shader.shaderId,
            shaderName: shader.shaderName,
            shaderCategory: shader.shaderCategory,
            fragmentCode: shader.fragmentCode,
            vertexCode: shader.vertexCode,
            parameters: shader.parameters,
            bpm: shader.bpm,
            beat: currentBeat,
            time: currentTime,
            thumbnailHash: shader.thumbnailHash
        )
        
        sendMessage(type: .shaderBroadcast, payload: newBroadcast)
    }
    
    // MARK: - Handle Received Messages
    
    private func handleReceivedMessage(_ message: ShaderSyncMessage, from peer: MCPeerID) {
        switch message.type {
        case .receiverInfo:
            if let info = message.decode(ReceiverState.self) {
                receiverStates[info.id] = info
                print("📡 ShaderSync: Updated receiver info from \(peer.displayName)")
            }
            
        case .requestShader:
            // Receiver requested current shader
            if let shader = currentShader {
                sendMessage(type: .shaderBroadcast, payload: shader)
                if let thumb = currentThumbnail {
                    let thumbData = ShaderThumbnail(
                        deviceName: deviceName,
                        shaderId: shader.shaderId,
                        image: thumb
                    )
                    sendMessage(type: .shaderThumbnail, payload: thumbData)
                }
            }
            
        case .remoteParameterChange:
            if let change = message.decode(RemoteParameterChange.self) {
                // Notify app that a remote parameter change was requested
                NotificationCenter.default.post(
                    name: .shaderSyncRemoteParameterChange,
                    object: nil,
                    userInfo: [
                        "parameterName": change.parameterName,
                        "newValue": change.newValue
                    ]
                )
            }
            
        case .assignToLayer:
            if let command = message.decode(AssignToLayerCommand.self) {
                print("📡 ShaderSync: Assigned to layer \(command.targetLayerIndex) on receiver")
            }
            
        default:
            break
        }
    }
}

// MARK: - MCSessionDelegate

extension ShaderSyncService: MCSessionDelegate {
    
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            switch state {
            case .connected:
                if !connectedReceivers.contains(peerID) {
                    connectedReceivers.append(peerID)
                }
                isConnected = !connectedReceivers.isEmpty
                connectionStatus = "Połączono z \(connectedReceivers.count) odbiornikiem(ami)"
                print("📡 ShaderSync: Connected to \(peerID.displayName)")
                
                // Send current shader to newly connected receiver
                if let shader = currentShader {
                    sendMessage(type: .shaderBroadcast, payload: shader)
                }
                
            case .notConnected:
                connectedReceivers.removeAll { $0 == peerID }
                isConnected = !connectedReceivers.isEmpty
                connectionStatus = connectedReceivers.isEmpty ? "Oczekuję na połączenie..." : "Połączono z \(connectedReceivers.count) odbiornikiem(ami)"
                print("📡 ShaderSync: Disconnected from \(peerID.displayName)")
                
            case .connecting:
                connectionStatus = "Łączenie z \(peerID.displayName)..."
                print("📡 ShaderSync: Connecting to \(peerID.displayName)")
                
            @unknown default:
                break
            }
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(ShaderSyncMessage.self, from: data) else {
            print("❌ ShaderSync: Failed to decode message from \(peerID.displayName)")
            return
        }
        
        Task { @MainActor in
            handleReceivedMessage(message, from: peerID)
        }
    }
    
    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension ShaderSyncService: MCNearbyServiceAdvertiserDelegate {
    
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations from receivers
        print("📡 ShaderSync: Received invitation from \(peerID.displayName)")
        
        Task { @MainActor in
            // Check if this is a receiver (from LayerMapper MApp)
            if let context = context,
               let info = try? JSONDecoder().decode([String: String].self, from: context),
               info["role"] == ShaderSyncRole.receiver.rawValue {
                invitationHandler(true, self.session)
                print("📡 ShaderSync: Accepted invitation from receiver \(peerID.displayName)")
            } else {
                // Accept anyway for now
                invitationHandler(true, self.session)
            }
        }
    }
    
    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("❌ ShaderSync: Failed to start advertising: \(error)")
        Task { @MainActor in
            connectionStatus = "Błąd: \(error.localizedDescription)"
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let shaderSyncRemoteParameterChange = Notification.Name("shaderSyncRemoteParameterChange")
}
