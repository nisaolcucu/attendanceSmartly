//
//  loginViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 28.11.2024.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class loginViewController: UIViewController {
    
    let database = Database.database().reference()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        validateLogin()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login Page for Students"
    }
    func validateLogin() {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    self.showAlert(message: "Giriş yapılamadı: \(e.localizedDescription)")
                } else if let userUID = Auth.auth().currentUser?.uid {
                    // Doğru düğüme erişim (students)
                    self.database.child("students").child(userUID).observeSingleEvent(of: .value) { snapshot in
                        if let userData = snapshot.value as? [String: Any],
                           let role = userData["role"] as? String {
                            if role == "students" {
                                self.performSegue(withIdentifier: "goToProfile", sender: self)
                            } else {
                                self.showAlert(message: "Bu giriş ekranı sadece öğrenciler içindir.")
                                try? Auth.auth().signOut()
                            }
                        } else {
                            self.showAlert(message: "Kullanıcı verileri bulunamadı.")
                        }
                    }
                }
            }
        } else {
            self.showAlert(message: "Lütfen tüm alanları doldurun.")
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

class loginViewController: UIViewController {
    
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
                        self.performSegue(withIdentifier: "goToProfile", sender: self)
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
