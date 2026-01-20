//
//  ShaderSyncModels.swift
//  LM_GLSL
//
//  Shared models for shader synchronization between
//  GLSL Shader App (Source) and LayerMapper MApp (Receiver)
//
//  This file should be shared/duplicated in LayerMapperLaser project
//
//  Created: January 2026
//

import Foundation
import UIKit

// MARK: - Protocol Version

struct ShaderSyncProtocol {
    static let version = "1.0"
    static let serviceType = "lm-shader-sync"  // Max 15 chars
}

// MARK: - Message Types

enum ShaderSyncMessageType: String, Codable {
    // Source → Receiver
    case shaderBroadcast       // Full shader state broadcast
    case parameterUpdate       // Real-time parameter changes only
    case shaderThumbnail       // Optional thumbnail image
    case folderSync            // Folder list and assignments sync
    
    // Receiver → Source (bi-directional control)
    case requestShader         // Request current shader from source
    case remoteParameterChange // Remote control of parameters
    case assignToLayer         // Assign this shader to specific layer
    case requestFolders        // Request folder list from source
    
    // Connection management
    case heartbeat
    case sourceInfo            // Source device info
    case receiverInfo          // Receiver device info
}

// MARK: - Device Role

enum ShaderSyncRole: String, Codable {
    case source     // GLSL Shader App - creates and broadcasts shaders
    case receiver   // LayerMapper MApp - receives and renders shaders
}

// MARK: - Source Device Info

/// Information about the shader source device
struct ShaderSourceInfo: Codable, Identifiable {
    var id: String { deviceName }  // Use device name as ID
    let deviceName: String      // "Denis's iPhone" - primary identifier
    let appVersion: String      // "1.0"
    let isActive: Bool          // Currently active/broadcasting
    let lastSeen: Date
    
    init(
        deviceName: String = UIDevice.current.name,
        appVersion: String = "1.0",
        isActive: Bool = true
    ) {
        self.deviceName = deviceName
        self.appVersion = appVersion
        self.isActive = isActive
        self.lastSeen = Date()
    }
}

// MARK: - Shader Parameter (Sync Version)

/// Lightweight parameter for sync (matching ShaderParameter in GLSL app)
struct SyncShaderParameter: Codable, Identifiable {
    let id: UUID
    let name: String            // Variable name in shader
    let displayName: String     // User-friendly name
    let type: String            // "slider" or "toggle"
    let minValue: Float
    let maxValue: Float
    let currentValue: Float
    
    init(from param: Any) {
        // This will be properly typed when integrated
        self.id = UUID()
        self.name = ""
        self.displayName = ""
        self.type = "slider"
        self.minValue = 0
        self.maxValue = 1
        self.currentValue = 0.5
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String,
        type: String = "slider",
        minValue: Float = 0,
        maxValue: Float = 1,
        currentValue: Float = 0.5
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName
        self.type = type
        self.minValue = minValue
        self.maxValue = maxValue
        self.currentValue = currentValue
    }
}

// MARK: - Shader Broadcast

/// Full shader state broadcast from Source
struct ShaderBroadcast: Codable {
    let deviceName: String          // Source device name - primary identifier
    let timestamp: Date
    
    // Shader identification
    let shaderId: UUID
    let shaderName: String
    let shaderCategory: String
    
    // Shader code
    let fragmentCode: String
    let vertexCode: String?
    
    // Parameters
    let parameters: [SyncShaderParameter]
    
    // Timing info (for BPM sync)
    let bpm: Double?
    let beat: Double?
    let time: Double              // Current shader time
    
    // Optional thumbnail hash (for caching)
    let thumbnailHash: String?
    
    init(
        deviceName: String,
        shaderId: UUID,
        shaderName: String,
        shaderCategory: String,
        fragmentCode: String,
        vertexCode: String? = nil,
        parameters: [SyncShaderParameter] = [],
        bpm: Double? = nil,
        beat: Double? = nil,
        time: Double = 0,
        thumbnailHash: String? = nil
    ) {
        self.deviceName = deviceName
        self.timestamp = Date()
        self.shaderId = shaderId
        self.shaderName = shaderName
        self.shaderCategory = shaderCategory
        self.fragmentCode = fragmentCode
        self.vertexCode = vertexCode
        self.parameters = parameters
        self.bpm = bpm
        self.beat = beat
        self.time = time
        self.thumbnailHash = thumbnailHash
    }
}

// MARK: - Parameter Update (Lightweight)

/// Real-time parameter update (sent frequently)
struct ParameterUpdate: Codable {
    let deviceName: String
    let timestamp: Date
    let shaderId: UUID
    
    // Only changed parameters
    let parameterValues: [String: Float]  // name -> value
    
    // Timing info
    let time: Double
    let beat: Double?
    
    init(
        deviceName: String,
        shaderId: UUID,
        parameterValues: [String: Float],
        time: Double,
        beat: Double? = nil
    ) {
        self.deviceName = deviceName
        self.timestamp = Date()
        self.shaderId = shaderId
        self.parameterValues = parameterValues
        self.time = time
        self.beat = beat
    }
}

// MARK: - Shader Thumbnail

/// Compressed thumbnail data
struct ShaderThumbnail: Codable {
    let deviceName: String
    let shaderId: UUID
    let thumbnailData: Data     // JPEG compressed
    let hash: String
    
    init(deviceName: String, shaderId: UUID, image: UIImage) {
        self.deviceName = deviceName
        self.shaderId = shaderId
        self.thumbnailData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.hash = "\(shaderId.uuidString)-\(Date().timeIntervalSince1970)"
    }
}

// MARK: - Assign to Layer Command

/// Command to assign shader to specific layer on receiver
struct AssignToLayerCommand: Codable {
    let deviceName: String
    let targetLayerIndex: Int
    let autoPlay: Bool
    
    init(deviceName: String, targetLayerIndex: Int, autoPlay: Bool = true) {
        self.deviceName = deviceName
        self.targetLayerIndex = targetLayerIndex
        self.autoPlay = autoPlay
    }
}

// MARK: - Remote Parameter Change

/// Remote control of parameter from receiver
struct RemoteParameterChange: Codable {
    let deviceName: String      // Target source device
    let parameterName: String
    let newValue: Float
}

// MARK: - Sync Message Envelope

/// Wrapper for all shader sync messages
struct ShaderSyncMessage: Codable {
    let type: ShaderSyncMessageType
    let payload: Data
    let senderId: String
    let senderName: String
    let senderRole: ShaderSyncRole
    let timestamp: Date
    let protocolVersion: String
    
    init<T: Codable>(type: ShaderSyncMessageType, payload: T, senderId: String, senderName: String, senderRole: ShaderSyncRole) {
        self.type = type
        self.payload = (try? JSONEncoder().encode(payload)) ?? Data()
        self.senderId = senderId
        self.senderName = senderName
        self.senderRole = senderRole
        self.timestamp = Date()
        self.protocolVersion = ShaderSyncProtocol.version
    }
    
    /// Decode payload to specific type
    func decode<T: Codable>(_ type: T.Type) -> T? {
        try? JSONDecoder().decode(type, from: payload)
    }
    
    /// Encode message to Data
    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

// MARK: - Receiver State

/// State of connected receivers (for Source UI)
struct ReceiverState: Codable, Identifiable {
    let id: String
    let deviceName: String
    let isConnected: Bool
    let assignedLayers: [Int]   // Which layers are using this source's shader
    let lastSeen: Date
}

// MARK: - Multi-Source State (for Receiver)

/// Track multiple sources on receiver side
struct MultiSourceState: Codable {
    var sources: [String: ShaderSourceInfo]     // deviceName -> info
    var activeShaders: [String: ShaderBroadcast]   // deviceName -> shader
    var thumbnails: [String: Data]                 // deviceName -> thumbnail data
    
    init() {
        self.sources = [:]
        self.activeShaders = [:]
        self.thumbnails = [:]
    }
    
    mutating func updateSource(_ info: ShaderSourceInfo) {
        sources[info.deviceName] = info
    }
    
    mutating func updateShader(_ broadcast: ShaderBroadcast) {
        activeShaders[broadcast.deviceName] = broadcast
    }
    
    mutating func updateThumbnail(deviceName: String, data: Data) {
        thumbnails[deviceName] = data
    }
    
    func getShader(for deviceName: String) -> ShaderBroadcast? {
        activeShaders[deviceName]
    }
    
    var connectedSourceCount: Int {
        sources.values.filter { $0.isActive }.count
    }
}

// MARK: - Constants

extension ShaderSyncProtocol {
    /// Parameter update frequency (Hz)
    static let parameterUpdateRate: Double = 30.0
    
    /// Full state broadcast interval (seconds)
    static let fullBroadcastInterval: TimeInterval = 1.0
    
    /// Heartbeat interval (seconds)
    static let heartbeatInterval: TimeInterval = 2.0
}

// MARK: - Folder Sync Models

/// Folder information for sync (matches ShaderFolder in GLSL app)
struct SyncShaderFolder: Codable, Identifiable {
    let id: UUID
    let name: String
    let colorHex: String
    let iconName: String
    let order: Int
    
    init(id: UUID = UUID(), name: String, colorHex: String = "#808080", iconName: String = "folder.fill", order: Int = 0) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.order = order
    }
}

/// Folder assignment for sync - maps shader names to folder names
struct SyncFolderAssignment: Codable {
    let shaderName: String
    let folderNames: [String]
}

/// Full folder sync payload
struct FolderSyncPayload: Codable {
    let deviceName: String
    let timestamp: Date
    let folders: [SyncShaderFolder]
    let assignments: [SyncFolderAssignment]  // shaderName -> [folderNames]
    
    init(deviceName: String, folders: [SyncShaderFolder], assignments: [SyncFolderAssignment]) {
        self.deviceName = deviceName
        self.timestamp = Date()
        self.folders = folders
        self.assignments = assignments
    }
}
