//
//  HKHealthHelper.swift
//  HealthkitApp (iOS)
//
//  Created by Jatin Garg on 07/07/21.
//

import Foundation
import HealthKit

enum HealthKitError: Error {
    case notAvailable
    case weightNotAvailable
    case heightNotAvailable
    case stepsNotAvailable
    case stepsNoRecord
    case calorieBurntNotAvailable
    case caloriesBurntNoRecord
    case heartRateNotAvailable
}

struct HealthKitDataType {
    static let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
    static let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)
    static let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
    static let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)
    static let height = HKObjectType.quantityType(forIdentifier: .height)
    static let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)
    static let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    static let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
    static let steps = HKObjectType.quantityType(forIdentifier: .stepCount)
}

extension HealthKitError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notAvailable:
            return "Health kit isn't available."
        case .weightNotAvailable:
            return "Weight property is not available"
        case .heightNotAvailable:
            return "Weight property is not available"
        case .stepsNotAvailable:
            return "Steps aren't available"
        case .stepsNoRecord:
            return "Steps not logged for the date"
        case .calorieBurntNotAvailable:
            return "Calories Data not available"
        case .caloriesBurntNoRecord:
            return "No Record of calorie"
        case .heartRateNotAvailable:
            return "Heart Rate Data not available"
        }
    }
}

class HKHealthHelper {
    
    static let healthKitStore = HKHealthStore()
    
    static func getMostRecentSample(for sampleType: HKSampleType,
                                    completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                completion(mostRecentSample, nil)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    static func authorizeHealthKit(permissions: Array<HKObjectType> ,completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitError.notAvailable)
            return
        }
        
        healthKitStore.requestAuthorization(toShare: nil, read: Set(permissions)) { success, error in
            completion(success, error)
        }
    }
    
    static func getSex(completion: @escaping (String, Error?) -> Void) {
        do {
            let sex = try healthKitStore.biologicalSex().biologicalSex
            switch sex {
            case .male:
                completion("Male", nil)
            case .female:
                completion("Female", nil)
            case .other:
                completion("Others", nil)
            default:
                completion("Not Set", nil)
            }
        } catch {
            completion("", error)
        }
    }
    
    static func getBloodType(completion: @escaping (String, Error?) -> Void) {
        do {
            let bloodType = try healthKitStore.bloodType().bloodType
            switch bloodType {
            case .aNegative :
                completion("A-", nil)
            case .aPositive:
                completion("A+", nil)
            case .abNegative:
                completion("Ab-", nil)
            case .abPositive:
                completion("Ab+", nil)
            case .bNegative:
                completion("b-", nil)
            case .bPositive:
                completion("B+", nil)
            case .oNegative:
                completion("O-", nil)
            case .oPositive:
                completion("O+", nil)
            default:
                completion("Not Set", nil)
            }
        } catch {
            completion("", error)
        }
    }
    
    static func getDOB(completion: @escaping (Int, Error?) -> Void) {
        do {
            let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
            let today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                              from: today)
            let thisYear = todayDateComponents.year!
            let age = thisYear - birthdayComponents.year!
            completion(age, nil)
        } catch {
            completion(0, error)
        }
    }
    
    static func getWeightInKg(completion: @escaping(Double?, Error?) -> Void) {
        guard let weight = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            completion(nil, HealthKitError.weightNotAvailable)
            return
        }
        self.getMostRecentSample(for: weight) { samples, error in
            guard let sample = samples else {
                completion(nil, error ?? HealthKitError.weightNotAvailable)
                return
            }
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weightInKilograms, nil)
        }
    }
    
    static func getHeightInMeters(completion: @escaping(Double?, Error?) -> Void) {
        guard let height = HKSampleType.quantityType(forIdentifier: .height) else {
            completion(nil, HealthKitError.heightNotAvailable)
            return
        }
        self.getMostRecentSample(for: height) { samples, error in
            guard let sample = samples else {
                completion(nil, error ?? HealthKitError.heightNotAvailable)
                return
            }
            let heightInMeter = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(heightInMeter, nil)
        }
    }
    
    static func getTodayStepsMoved(completion: @escaping(Double?, Error?) -> Void) {
        guard let stepsProperty = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, HealthKitError.stepsNotAvailable)
            return
        }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        let query = HKStatisticsQuery(
            quantityType: stepsProperty,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, HealthKitError.stepsNoRecord)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()), nil)
        }
        
        HKHealthStore().execute(query)
    }
    
    static func getCaloriesBurntToday(completion: @escaping(Double?, Error?) -> Void) {
        guard let calorieProperty = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, HealthKitError.calorieBurntNotAvailable)
            return
        }
        let now = Date()
        var totalBurnedEnergy = Double()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(sampleType: calorieProperty,
                               predicate: predicate,
                               limit: 0,
                               sortDescriptors: nil) { _, result, error in
            guard let result = result else {
                completion(nil, HealthKitError.stepsNoRecord)
                return
            }
            DispatchQueue.main.async {
                for activity in result as! [HKQuantitySample]
                {
                    let calories = activity.quantity.doubleValue(for: HKUnit.kilocalorie())
                    totalBurnedEnergy = totalBurnedEnergy + calories
                }
                completion(totalBurnedEnergy, nil)
            }
        }
        HKHealthStore().execute(query)
    }
    
    static func getHeartRate(completion: @escaping(Double?, Error?) -> Void) {
        guard let heartRateProperty = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, HealthKitError.calorieBurntNotAvailable)
            return
        }
        self.getMostRecentSample(for: heartRateProperty) { samples, error in
            guard let sample = samples else {
                completion(nil, HealthKitError.heartRateNotAvailable)
                return
            }
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate, nil)
        }
    }
}
