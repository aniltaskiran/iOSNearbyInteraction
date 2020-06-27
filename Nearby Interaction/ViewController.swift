//
//  ViewController.swift
//  Nearby Interaction
//
//  Created by Anıl on 27.06.2020.
//

import UIKit
import NearbyInteraction

final class ViewController: UIViewController {
    @IBOutlet weak var coordinateContainerView: UIView!
    @IBOutlet weak var connectedPersonLabel: UILabel!
    @IBOutlet weak var connectedPersonContainer: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NearbyInteractionManager.instance.delegate = self
        NearbyInteractionManager.instance.start()
    }
    
    private func updateConnectedPersonFrame(object: NINearbyObject) {
        let size = connectedPersonContainer.frame.size
        let containerWidth = coordinateContainerView.frame.width
        let containerHeight = coordinateContainerView.frame.height
        let point = Point(distance: object.distance, direction: object.direction)
        
        if let azimuth = point.azimuth, let elevation = point.elevation {
            let origin = CGPoint(x: (containerWidth / 2) + CGFloat(azimuth) * (containerWidth / 2),
                                 y: (containerHeight / 2) - CGFloat(elevation) * (containerHeight / 2))
            connectedPersonContainer.frame = .init(origin: .init(x: origin.x - size.width/2 , y: origin.y - size.height/2), size: size)
        }
    }
}

extension ViewController: NearbyInteractionManagerDelegate {
    func didUpdateNearbyObjects(objects: [NINearbyObject]) {
        DispatchQueue.main.async { [weak self] in
            guard let object = objects.first else { return }
            self?.updateConnectedPersonFrame(object: object)
        }
    }
}

