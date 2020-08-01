//
//  FormatDisplay.swift
//  RaceMe
//
//  Created by Kirlos Yousef on 2020. 03. 02..
//  Copyright © 2020. Kirlos Yousef. All rights reserved.
//

import Foundation


struct FormatDisplay {
    static func distance(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return FormatDisplay.distance(distanceMeasurement)
    }
    
    static func distance(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        return formatter.string(from: distance)
    }
    
    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    static func pace(distance: Measurement<UnitLength>, seconds: Int, outputUnit: UnitSpeed) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit] // 1
        let speedMagnitude = seconds != 0 ? distance.value / Double(seconds) : 0
        let speed = Measurement(value: speedMagnitude, unit: UnitSpeed.metersPerSecond)
        return formatter.string(from: speed.converted(to: outputUnit))
    }
    
    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    static func getDistanceWith(meters: Double) -> String{
        var unit = UnitLength.kilometers
        var unitText = "km"
        
        if UserDefaults.standard.getDistanceUnit() == "Miles"{
            unit = UnitLength.miles
            unitText = "mi"
        }
        
        let distanceMeasurement = Measurement(value: meters, unit: UnitLength.meters).converted(to: unit)
        
        var distance = distanceMeasurement.value.description
        
        distance = String(format: "%.2f", arguments: [distanceMeasurement.value])
        
        
        return "\(distance) \(unitText)"
    }
}
