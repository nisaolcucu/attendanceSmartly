//
//  ViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 28.11.2024.
//

import UIKit
//import CoreLocation

class ViewController: UIViewController {

    //var locationManager: CLLocationManager?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func loginTeacherbutton(_ sender: Any) {
        
    }
    
    @IBAction func loginStudentbutton(_ sender: Any) {
        
    }
    
    @IBAction func creatingAccountbutton(_ sender: Any) {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       /* locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
        requestOnTimeLocation()
        */
        //-------------------------------------------------for the animation of title-----------------------------------------------------------------
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "SMART ATTENDANCE"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        //-------------------------------------------------for the animation of title-----------------------------------------------------------------
    }
   // private func requestOnTimeLocation() {
     //       locationManager?.requestLocation()
     //   }


}
/*
extension ViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
        case .authorizedAlways:
                    print("When user select option Change to Always Allow")
                case .authorizedWhenInUse:
                    print("When user select option Allow While Using App or Allow Once")
                    // 2
                    locationManager?.requestAlwaysAuthorization()
                default:
                    print("default")
        }
    }
    
    //for the error handling
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager!.stopUpdatingLocation()

        if let clErr = error as? CLError {
            switch clErr.code {
            case .locationUnknown, .denied, .network:
                print("Location request failed with error: \(clErr.localizedDescription)")
            case .headingFailure:
                print("Heading request failed with error: \(clErr.localizedDescription)")
            case .rangingUnavailable, .rangingFailure:
                print("Ranging request failed with error: \(clErr.localizedDescription)")
            case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                print("Region monitoring request failed with error: \(clErr.localizedDescription)")
            default:
                print("Unknown location manager error: \(clErr.localizedDescription)")
            }
        } else {
            print("Unknown error occurred while handling location manager error: \(error.localizedDescription)")
        }
    }
    
}
*/

