//
//  PointHelper.swift
//  Nearby Interaction
//
//  Created by Anıl on 27.06.2020.
//

import NearbyInteraction

struct Point {
    let azimuth: Float?
    let elevation: Float?
    let distance: String?
    
    init(distance: Float?, direction: simd_float3?) {
        azimuth = direction.map(Point.azimuthValue(_:))
        elevation = direction.map(Point.elevationValue(_:))
        
        if let distance = distance {
            self.distance = String(format: "%0.2f m", distance)
        } else {
            self.distance = nil
        }
        
        details()
    }
    
    private func details() {
        if elevation != nil {
            if elevation! < 0 {
                print("down")
            } else {
                print("up")
            }
            
        }
        
        if azimuth != nil {
                if azimuth! < 0 {
                    print("left")
                } else {
                    print("right")
                }
            
            _ = String(format: "% 3.0f°", azimuth!.radiansToDegrees)
        }
    }
    
    // Provides the azimuth from an argument 3D directional.
    private static func azimuthValue(_ direction: simd_float3) -> Float { asin(direction.x) }
    
    // Provides the elevation from the argument 3D directional.
    private static func elevationValue(_ direction: simd_float3) -> Float { atan2(direction.z, direction.y) + .pi / 2 }

}
