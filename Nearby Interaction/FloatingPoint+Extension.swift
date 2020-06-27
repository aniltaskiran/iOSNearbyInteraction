//
//  AzimuthElevation+Extension.swift
//  Nearby Interaction
//
//  Created by Anıl on 27.06.2020.
//

import simd

// Converts degrees to radians, and back.
extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
