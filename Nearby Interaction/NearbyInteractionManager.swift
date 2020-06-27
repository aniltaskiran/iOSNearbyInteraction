//
//  NearbyInteractionManager.swift
//  Nearby Interaction
//
//  Created by Anıl on 27.06.2020.
//

import NearbyInteraction
import MultipeerConnectivity

protocol NearbyInteractionManagerDelegate: class {
    func didUpdateNearbyObjects(objects: [NINearbyObject])
}

final class NearbyInteractionManager: NSObject {
    static let instance = NearbyInteractionManager()
    var session: NISession?
    weak var delegate: NearbyInteractionManagerDelegate?
    
    func start() {
        session = NISession()
        session?.delegate = self
        MultipeerConnectivityManager.instance.delegate = self
        MultipeerConnectivityManager.instance.startBrowsingForPeers()
    }
        
    private var discoveryTokenData: Data {
        guard let token = session?.discoveryToken,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            fatalError("can't convert token to data")
        }
        
        return data
    }
}

extension NearbyInteractionManager: MultipeerConnectivityManagerDelegate {
    func connectedDevicesChanged(devices: [String]) {
        print("connected devices changed \(devices)")
    }
    
    func connectedToDevice() {
        print("connected to device")
        MultipeerConnectivityManager.instance.shareDiscoveryToken(data: discoveryTokenData)
    }
    
    func receivedDiscoveryToken(data: Data) {
        print("data received")
        guard let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
            fatalError("Unexpectedly failed to encode discovery token.")
        }
        let configuration = NINearbyPeerConfiguration(peerToken: token)
        session?.run(configuration)
    }
}

// MARK: - NISessionDelegate
extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        delegate?.didUpdateNearbyObjects(objects: nearbyObjects)
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {}
    func sessionWasSuspended(_ session: NISession) {}
    func sessionSuspensionEnded(_ session: NISession) {}
    func session(_ session: NISession, didInvalidateWith error: Error) {}
}
