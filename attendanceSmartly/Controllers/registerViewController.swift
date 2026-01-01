//
//  registerViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 28.11.2024.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

class registerViewController: UIViewController {
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    let database = Database.database().reference()
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Registeration"
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToLoginAfterRegister", sender: self)
    }
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text,
              !email.isEmpty,
              !password.isEmpty,
              !name.isEmpty else {
            print("Email, şifre veya isim boş.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e.localizedDescription)
            } else if let user = authResult?.user {
                // Kullanıcının rolünü belirle
                let selectedRoleIndex = self.roleSegmentedControl.selectedSegmentIndex
                let role = (selectedRoleIndex == 0) ? "students" : "teachers"
                
                // Kullanıcı bilgilerini kaydet
                var userData: [String: Any] = [
                    "email": email,
                    "uid": user.uid,
                    "role": role,
                    "name": name
                ]
                // Eğer rol 'students' ise inClass değerini false olarak ekle
                            if role == "students" {
                                userData["inClass"] = false
                            }
                self.database.child(role).child(user.uid).setValue(userData) { error, _ in
                    if let error = error {
                        print("Database write error: \(error.localizedDescription)")
                    } else {
                        print("User successfully added to \(role) in database.")
                        
                        // Kayıt başarılı mesajı göster
                        DispatchQueue.main.async {
                            self.showSuccessAlert()
                        }
                    }
                }
            }
        }
    }
    
    // Başarılı kayıt uyarı mesajı
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Başarılı", message: "Kayıt başarılı!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { _ in
            // Giriş ekranına yönlendirme
            self.performSegue(withIdentifier: "goToLoginAfterRegister", sender: self)
        }))
        self.present(alert, animated: true)
    }
}

/*
import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase

class registerViewController: UIViewController {
    
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    let database = Database.database().reference()
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        guard let email = emailTextField.text,
                      let password = passwordTextField.text,
                      !email.isEmpty,
                      !password.isEmpty else {
                    print("Email veya şifre boş.")
                    return
                }
                
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        print(e.localizedDescription)
                    } else if let user = authResult?.user {
                        // Kullanıcının rolünü belirle
                        let selectedRoleIndex = self.roleSegmentedControl.selectedSegmentIndex
                        let role = (selectedRoleIndex == 0) ? "students" : "teachers"
                        
                        // Kullanıcı bilgilerini kaydet
                        let userData: [String: Any] = [
                            "email": email,
                            "uid": user.uid,
                            "role": role
                        ]
                        
                        self.database.child(role).child(user.uid).setValue(userData) { error, _ in
                            if let error = error {
                                print("Database write error: \(error.localizedDescription)")
                            } else {
                                print("User successfully added to \(role) in database.")
                                // Giriş ekranına yönlendirme
                                self.performSegue(withIdentifier: "goToLoginAfterRegister", sender: self)
                            }
                        }
                    }
                }
        /*
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else if let user = authResult?.user {
                    // Kullanıcı bilgilerini Realtime Database'e kaydet
                    let userData: [String: Any] = [
                        "email": email,
                        "uid": user.uid
                    ]
                    
                    self.database.child("users").child(user.uid).setValue(userData) { error, _ in
                        if let error = error {
                            print("Database write error: \(error)")
                        } else {
                            print("User successfully added to database.")
                            // ChatViewController'a geçiş
                            self.performSegue(withIdentifier: "goToLoginAfterRegister", sender: self)
                        }
                    }
                }
            }
        }
         */
    }
         
}

 /*
    // Kullanıcı bilgilerini Firestore'a kaydeden fonksiyon
        func saveStudentToFirestore(user: User) {
            let currentDate = Date()
            let studentData: [String: Any] = [
                "studentID": user.uid, // Firebase Authentication tarafından sağlanan benzersiz kullanıcı kimliği
                "email": user.email ?? "", // Kullanıcı e-postası
                "isHere": false, // Varsayılan olarak false
                "timestamp": currentDate // Mevcut cihaz tarihi ve saati
            ]
            
            // Firestore'da "students" koleksiyonuna kullanıcıyı ekler
            db.collection("students").document(user.uid).setData(studentData) { error in
                if let error = error {
                    print("Firestore'a veri kaydedilirken hata: \(error.localizedDescription)")
                } else {
                    print("Öğrenci bilgileri başarıyla Firestore'a kaydedildi.")
                }
            }
        }
    
  */


*/
