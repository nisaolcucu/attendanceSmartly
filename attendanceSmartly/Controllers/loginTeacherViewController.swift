//
//  loginTeacherViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 24.12.2024.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class loginTeacherViewController: UIViewController {
    
    let database = Database.database().reference()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        validateLogin()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login Page for Teachers"
    }
    func validateLogin() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                } else if let userUID = Auth.auth().currentUser?.uid {
                    self.database.child("teachers").child(userUID).observeSingleEvent(of: .value) { snapshot in
                        if let userData = snapshot.value as? [String: Any],
                           let role = userData["role"] as? String {
                            if role == "teachers" {
                                self.performSegue(withIdentifier: "goToTeacherProfile", sender: self)
                            } else {
                                self.showAlert(message: "Bu giriş ekranı sadece öğretmenler içindir.")
                                try? Auth.auth().signOut()
                            }
                        } else {
                            self.showAlert(message: "Kullanıcı rolü bulunamadı.")
                        }
                    }
                }
            }
        }
    }
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true)
        }
    }
}

/*
import Foundation
import UIKit
import FirebaseAuth

class loginTeacherViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginPressed(_ sender: UIButton) {
        validateLogin()
        
    }
    // Giriş doğrulama fonksiyonu
        func validateLogin() {
            if let email = emailTextField.text, let password = passwordTextField.text {
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        print(e)
                    } else {
                        self.performSegue(withIdentifier: "goToTeacherProfile", sender: self)
                    }
                }
        }
    
    // Uyarı mesajı gösterme fonksiyonu
        func showAlert(message: String) {
            let alert = UIAlertController(title: "Bilgi", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true)
        }
    
}
}
*/
