//
//  Permissions.swift
//  HealthkitApp (iOS)
//
//  Created by Jatin Garg on 07/07/21.
//

import Foundation

enum Permissions: String, CaseIterable {
    case dob = "DOB"
    case sex = "Sex"
    case bloodType = "Blood Type"
    case bodyMass = "Body Mass"
    case height = "Height"
    case weight = "Weight"
    case activeEnergy = "Active Energy"
    case steps = "Steps"
    case caloriesBurnt = "Calories Burnt"
    case heartRate = "Heart Rate"
}
