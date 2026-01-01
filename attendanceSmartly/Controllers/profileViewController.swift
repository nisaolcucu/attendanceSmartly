//
//  profileViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 28.11.2024.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class profileViewController: UIViewController, CLLocationManagerDelegate {
    
    let database = Database.database().reference()
    let locationManager = CLLocationManager()
    
    // Okulun konum koordinatları
    let schoolLocation = CLLocation(latitude: 37.07032, longitude: 37.36442) // Örnek: New York
    let allowedDistance: Double = 100.0 // Okul çevresi (metre)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Konum yöneticisi ayarları
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func hereButtonTapped(_ sender: UIButton) {
        locationManager.requestLocation() // Kullanıcının mevcut konumunu al
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            let distance = userLocation.distance(from: schoolLocation)
            if distance <= allowedDistance {
                markStudentAsInClass() // Eğer okul sınırları içerisindeyse işaretle
            } else {
                showAlert(message: "Okul sınırları içinde değilsiniz.") // Okulda değilse uyarı göster
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum alınamadı: \(error.localizedDescription)")
        showAlert(message: "Konum alınamadı. Lütfen tekrar deneyin.")
    }
    
    func markStudentAsInClass() {
        if let userUID = Auth.auth().currentUser?.uid {
            // `inClass` durumunu true olarak güncelle
            database.child("students").child(userUID).updateChildValues(["inClass": true]) { error, _ in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                } else {
                    print("User marked as in class.")
                    
                    // 50 dakika sonra `inClass` değerini false yap
                    Timer.scheduledTimer(withTimeInterval: 1 * 60, repeats: false) { _ in
                        self.database.child("students").child(userUID).updateChildValues(["inClass": false]) { error, _ in
                            if let error = error {
                                print("Error resetting status: \(error.localizedDescription)")
                            } else {
                                print("User marked as not in class.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logout()
    }
    func logout() {
        print("Logout fonksiyonu çağrıldı.") // Bu mesaj konsolda görünüyor mu?
        do {
            try Auth.auth().signOut()
            print("Başarıyla çıkış yapıldı.")
            if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "WelcomePage") {
                welcomeVC.modalPresentationStyle = .fullScreen
                welcomeVC.modalTransitionStyle = .crossDissolve
                present(welcomeVC, animated: true, completion: nil)
            }
        } catch let signOutError as NSError {
            print("Çıkış yapılamadı: \(signOutError.localizedDescription)")
            showAlert(message: "Çıkış işlemi başarısız. Lütfen tekrar deneyin.")
        }
    }
    
    
}

/*
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import FirebaseDatabase

 

// CLLocationManagerDelegate
class profileViewController: UIViewController, CLLocationManagerDelegate {
    let database = Database.database().reference()
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    // Okulun merkez koordinatları ve yarıçapı (örnek değerler)
        let schoolLatitude: Double = 40.123456 // Okulun enlem değeri
        let schoolLongitude: Double = 29.123456 // Okulun boylam değeri
        let schoolRadius: Double = 100.0 // Metre cinsinden okul sınırı
       
        override func viewDidLoad() {
            super.viewDidLoad()
            /*
            // Konum yöneticisini başlat
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    locationManager.startUpdatingLocation()
            */
        }
        
    @IBAction func hereButtonTapped(_ sender: UIButton) {
        // Kullanıcının oturum UID'sini al
        if let userUID = Auth.auth().currentUser?.uid {
            // 'inClass' değerini true olarak ayarla
            database.child("students").child(userUID).updateChildValues(["inClass": true]) { error, _ in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                } else {
                    print("User marked as in class.")
                    
                    // Timer başlat - 50 dakika (3000 saniye)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3000) {
                        self.database.child("students").child(userUID).updateChildValues(["inClass": false]) { error, _ in
                            if let error = error {
                                print("Error resetting status: \(error.localizedDescription)")
                            } else {
                                print("User's inClass status reset to false.")
                            }
                        }
                    }
                }
            }
        } else {
            print("No user is logged in.")
        }
    

                
            /*
            guard let currentLocation = locationManager.location else {
                        print("Konum alınamadı.")
                        return
                    }
            
            // Mevcut konumu kontrol et
                    let isInSchool = isWithinSchoolArea(location: currentLocation)

                    if isInSchool {
                        // Firestore'a öğrencinin "burada" bilgisi kaydedilir
                        let studentID = "12345" // Öğrenci kimliği
                        db.collection("students").document(studentID).setData([
                            "isHere": true,
                            "timestamp": Timestamp(date: Date()),
                            "location": [
                                "latitude": currentLocation.coordinate.latitude,
                                "longitude": currentLocation.coordinate.longitude
                            ]
                        ]) { error in
                            if let error = error {
                                print("Veri kaydedilemedi: \(error.localizedDescription)")
                            } else {
                                print("Öğrenci burada olarak kaydedildi!")
                            }
                        }
                    } else {
                        print("Öğrenci okul sınırları dışında!")
                    }
             */
        }
    // Okul sınırlarını kontrol eden fonksiyon
        func isWithinSchoolArea(location: CLLocation) -> Bool {
            let schoolLocation = CLLocation(latitude: schoolLatitude, longitude: schoolLongitude)
            let distance = location.distance(from: schoolLocation)
            return distance <= schoolRadius
        }
        
    }


*/

/* konumlu olan kısım
 import Foundation
 import UIKit
 import FirebaseFirestore
 import FirebaseAuth
 import CoreLocation
 import FirebaseDatabase

 class profileViewController: UIViewController, CLLocationManagerDelegate {
     let database = Database.database().reference()
     let db = Firestore.firestore()
     let locationManager = CLLocationManager()

     // Okulun koordinatlarını belirleyin
     let schoolLocation = CLLocation(latitude: 40.748817, longitude: -73.985428) // Okulun koordinatları (örnek)
     
     override func viewDidLoad() {
         super.viewDidLoad()

         // Konum izni talep et
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
         
         if CLLocationManager.locationServicesEnabled() {
             locationManager.startUpdatingLocation()
         }
     }

     @IBAction func hereButtonTapped(_ sender: UIButton) {
         // Kullanıcının oturum UID'sini al
         if let userUID = Auth.auth().currentUser?.uid {
             // Kullanıcının mevcut konumunu al
             if let currentLocation = locationManager.location {
                 // Okul ile kullanıcının konumu arasındaki mesafeyi hesapla
                 let distance = currentLocation.distance(from: schoolLocation) // Mesafeyi hesapla (metre cinsinden)
                 
                 if distance <= 100 { // 100 metre mesafede ise
                     // Okul sınırları içindeyse, Firebase'e inClass: true olarak güncelle
                     database.child("users").child(userUID).updateChildValues(["inClass": true]) { error, _ in
                         if let error = error {
                             print("Error updating status: \(error.localizedDescription)")
                         } else {
                             print("User marked as in class.")
                         }
                     }
                 } else {
                     print("Kullanıcı okul sınırları dışında.")
                     // Burada okul dışında olduğu için işlem yapmayabilirsiniz ya da başka bir şey yapabilirsiniz
                 }
             } else {
                 print("Kullanıcının konumu alınamadı.")
             }
         } else {
             print("No user is logged in.")
         }
     }
     
     // Konum güncellemeleri başarılı olursa
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         // Konum güncellemeleri burada işlenebilir, örneğin en son alınan konumu alabilirsiniz
     }
     
     // Konum alırken bir hata oluşursa
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("Konum alınamadı: \(error.localizedDescription)")
     }
 }

 */
