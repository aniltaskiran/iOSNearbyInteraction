//
//  MultipeerConnectivityManager.swift
//  Nearby Interaction
//
//  Created by Anıl on 27.06.2020.
//

import MultipeerConnectivity

protocol MultipeerConnectivityManagerDelegate: class {
    func connectedDevicesChanged(devices: [String])
    func receivedDiscoveryToken(data: Data)
    func connectedToDevice()
}

protocol MultipeerConnectivityManagerInterface {
    var connectedPeers: [MCPeerID] { get }
    var delegate: MultipeerConnectivityManagerDelegate? { get set }
    
    func stopBrowsingForPeers()
    func startBrowsingForPeers()
    func shareDiscoveryToken(data: Data)
}

final class MultipeerConnectivityManager: NSObject {
    static var instance: MultipeerConnectivityManagerInterface = MultipeerConnectivityManager()
    weak var delegate: MultipeerConnectivityManagerDelegate?
    
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private lazy var serviceAdvertiser: MCNearbyServiceAdvertiser = {
        return .init(peer: myPeerID, discoveryInfo: nil, serviceType: "aniltaskiran")
    }()
    private lazy var serviceBrowser: MCNearbyServiceBrowser = {
        return .init(peer: myPeerID, serviceType: "aniltaskiran")
    }()
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
}

extension MultipeerConnectivityManager: MultipeerConnectivityManagerInterface {
    var connectedPeers: [MCPeerID] { session.connectedPeers }
    
    func startBrowsingForPeers() {
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsingForPeers() {
        serviceBrowser.stopBrowsingForPeers()
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func shareDiscoveryToken(data: Data) {
        NSLog("%@", "send data to \(session.connectedPeers.count) peers")
        guard session.connectedPeers.count > 0 else { return }
        do {
            try self.session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
        catch let error {
            NSLog("%@", "Error for sending: \(error)")
        }
    }
}

extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session)
    }

}

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) { }
}

extension MultipeerConnectivityManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            delegate?.connectedToDevice()
        }
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        delegate?.connectedDevicesChanged(devices: session.connectedPeers.map{$0.displayName})
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data) from \(peerID.displayName)")
        delegate?.receivedDiscoveryToken(data: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) { }
    
}
