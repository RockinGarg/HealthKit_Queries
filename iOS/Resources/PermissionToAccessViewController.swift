//
//  PermissionToAccessViewController.swift
//  HealthkitApp (iOS)
//
//  Created by Jatin Garg on 07/07/21.
//

import UIKit
import HealthKit

class PermissionToAccessViewController: UIViewController {
    
    @IBOutlet weak var permissionListTableView: UITableView!
    @IBOutlet weak var viewBarButton: UIBarButtonItem!
    
    private var permissions = Permissions.allCases
    
    private var isPermissionGiven: Bool = false {
        didSet {
            viewBarButton.isEnabled = isPermissionGiven
        } willSet {
            viewBarButton.isEnabled = newValue
        }
    }
    
    private var permissionToAccess = Array<HKObjectType>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBarButton.isEnabled = false
        permissionListTableView.tableFooterView = UIView()
    }
    
    
    @IBAction func viewDataButtonAction(_ sender: UIBarButtonItem) {
        HKHealthHelper.getSex { sex, error in
            if let error = error {
                print("Error Getting Sex: \(error.localizedDescription)")
            } else {
                print("Sex: \(sex)")
            }
        }
        
        HKHealthHelper.getDOB { age, error in
            if let error = error {
                print("Error Getting Age: \(error.localizedDescription)")
            } else {
                print("Age: \(age)")
            }
            
        }
        
        HKHealthHelper.getBloodType { blood, error in
            if let error = error {
                print("Error Getting Blood Type: \(error.localizedDescription)")
            } else {
                print("Blood: \(blood)")
            }
            
        }
        
        HKHealthHelper.getWeightInKg { weight, error in
            if let error = error {
                print("Error Getting Weight: \(error.localizedDescription)")
            } else {
                print("Weight: \(weight ?? 0)")
            }
        }
        
        HKHealthHelper.getHeightInMeters { height, error in
            if let error = error {
                print("Error Getting height: \(error.localizedDescription)")
            } else {
                print("Height: \(height ?? 0)")
            }
        }
        
        HKHealthHelper.getTodayStepsMoved { steps, error in
            if let error = error {
                print("Error Getting Steps Moved: \(error.localizedDescription)")
            } else {
                print("Steps: \(steps ?? 0)")
            }
        }
        
        HKHealthHelper.getCaloriesBurntToday { calorie, error in
            if let error = error {
                print("Error Getting Calories: \(error.localizedDescription)")
            } else {
                print("Calorie: \(calorie ?? 0)")
            }
        }
        
        HKHealthHelper.getHeartRate { hb, error in
            if let error = error {
                print("Error Getting HB: \(error.localizedDescription)")
            } else {
                print("HB: \(hb ?? 0)")
            }
           
        }
    }
    
    @IBAction func fetchPermissions(_ sender: UIBarButtonItem) {
        if permissionToAccess.isEmpty {
            self.showAlert("Error", "No Permission Selected")
            return
        }
        
        /// Check for Apple Permissions
        HKHealthHelper.authorizeHealthKit(permissions: self.permissionToAccess) { success, error in
            DispatchQueue.main.async {
                self.isPermissionGiven = success
                if !success {
                    guard let error = error else {
                        print("Failed and empty error")
                        return
                    }
                    self.showAlert("Error", error.localizedDescription)
                } else {
                    /// View Data Screen
                }
            }
        }
    }
}

extension PermissionToAccessViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = permissions[indexPath.row].rawValue
            let lightSwitch = UISwitch(frame: CGRect.zero) as UISwitch
            lightSwitch.isOn = false
            lightSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
            lightSwitch.tag = indexPath.row
            cell.accessoryView = lightSwitch
            return cell
        }
        return UITableViewCell()
    }
    
    @objc
    func switchTriggered(sender: UISwitch) {
        switch permissions[sender.tag] {
        case .activeEnergy:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.activeEnergy })
            if sender.isOn {
                guard let permission = HealthKitDataType.activeEnergy else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .dob:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.dateOfBirth })
            if sender.isOn {
                guard let permission = HealthKitDataType.dateOfBirth else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .sex:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.biologicalSex })
            if sender.isOn {
                guard let permission = HealthKitDataType.biologicalSex else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .bloodType:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.bloodType })
            if sender.isOn {
                guard let permission = HealthKitDataType.bloodType else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .heartRate:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.heartRate })
            if sender.isOn {
                guard let permission = HealthKitDataType.heartRate else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .caloriesBurnt:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.activeEnergy })
            if sender.isOn {
                guard let permission = HealthKitDataType.activeEnergy else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .height:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.height })
            if sender.isOn {
                guard let permission = HealthKitDataType.height else {
                    break
                }
                permissionToAccess.append(permission)
            }
        case .steps:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.steps })
            if sender.isOn {
                guard let permission = HealthKitDataType.steps else {
                    break
                }
                permissionToAccess.append(permission)
            }
        default:
            permissionToAccess = permissionToAccess.filter({ $0 != HealthKitDataType.bodyMass })
            if sender.isOn {
                guard let permission = HealthKitDataType.bodyMass else {
                    break
                }
                permissionToAccess.append(permission)
            }
        }
    }
}
