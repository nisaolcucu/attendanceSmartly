//
//  teacherProfileViewController.swift
//  attendanceSmartly
//
//  Created by nisa on 24.12.2024.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class teacherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let database = Database.database().reference()
    var studentsList: [(uid: String, name: String, inClass: Bool)] = [] // Öğrencilerin UID'leri, adları ve yoklama durumları

    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        logout()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            print("Başarıyla çıkış yapıldı.")
            if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "WelcomePage") {
                welcomeVC.modalPresentationStyle = .fullScreen
                welcomeVC.modalTransitionStyle = .crossDissolve
                present(welcomeVC, animated: true, completion: nil)
            }
        } catch let error {
            print("Çıkış yapılamadı: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Hata", message: "Çıkış yapılamadı. Lütfen tekrar deneyin.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kullanıcının UID'sini al ve öğretmen olup olmadığını kontrol et
        guard let teacherUID = Auth.auth().currentUser?.uid else {
            print("Giriş yapan kullanıcı bulunamadı.")
            return
        }

        // Kullanıcının öğretmen olup olmadığını kontrol et
        database.child("teachers").child(teacherUID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("Giriş yapan öğretmen: \(teacherUID)")
                self.loadStudentsInClass() // Öğrencileri yükleme fonksiyonunu çağır
            } else {
                print("Giriş yapan kullanıcı öğretmen değil.")
                let alert = UIAlertController(title: "Hata", message: "Bu ekran yalnızca öğretmenler içindir.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }

        tableView.delegate = self
        tableView.dataSource = self
    }

    func loadStudentsInClass() {
        // Öğrenci düğümündeki tüm öğrencileri al
        database.child("students").observeSingleEvent(of: .value) { snapshot in
            if let students = snapshot.value as? [String: [String: Any]] {
                self.studentsList.removeAll() // Listeyi sıfırla
                for (studentUID, studentData) in students {
                    if let name = studentData["name"] as? String,
                       let inClass = studentData["inClass"] as? Bool {
                        self.studentsList.append((uid: studentUID, name: name, inClass: inClass))
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = studentsList[indexPath.row]
        cell.textLabel?.text = student.name
        cell.detailTextLabel?.text = student.inClass ? "Here" : "Not Here"
        return cell
    }

    // TableView Delegate Method - Hücreye tıklandığında
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = studentsList[indexPath.row]
        let studentName = student.name

        // Uyarı penceresi oluştur
        let alert = UIAlertController(title: "Yoklama Güncelle", message: "\(studentName) için yoklama durumu seçin:", preferredStyle: .alert)

        // "Here" seçeneği
        alert.addAction(UIAlertAction(title: "Here", style: .default, handler: { _ in
            self.updateAttendance(for: indexPath.row, to: true)
        }))

        // "Not Here" seçeneği
        alert.addAction(UIAlertAction(title: "Not Here", style: .default, handler: { _ in
            self.updateAttendance(for: indexPath.row, to: false)
        }))

        // İptal seçeneği
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))

        // Uyarı penceresini göster
        self.present(alert, animated: true, completion: nil)
    }

    func updateAttendance(for index: Int, to inClass: Bool) {
        let student = studentsList[index]
        let studentUID = student.uid

        // Firebase'deki veriyi güncelle
        database.child("students").child(studentUID).updateChildValues(["inClass": inClass]) { error, _ in
            if let error = error {
                print("Error updating attendance: \(error.localizedDescription)")
            } else {
                print("Attendance updated for student \(studentUID).")
            }
        }

        // Yerel listeyi güncelle
        studentsList[index].inClass = inClass

        // TableView'ı yenile
        tableView.reloadData()
    }

    // Reset Attendance Function
    @IBAction func resetAttendance(_ sender: UIButton) {
        for (index, student) in studentsList.enumerated() {
            let studentUID = student.uid

            // Firebase'deki inClass değerini false yap
            database.child("students").child(studentUID).updateChildValues(["inClass": false]) { error, _ in
                if let error = error {
                    print("Error resetting attendance for student \(studentUID): \(error.localizedDescription)")
                } else {
                    print("Attendance reset for student \(studentUID).")
                }
            }

            // Yerel listeyi güncelle
            studentsList[index].inClass = false
        }

        // TableView'ı yenile
        tableView.reloadData()

        // Bilgilendirme mesajı
        let alert = UIAlertController(title: "Başarılı", message: "Tüm yoklamalar sıfırlandı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// en son kodum
/*
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class teacherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let database = Database.database().reference()
    var studentsInClass: [String: Bool] = [:] // Öğrencilerin UID'leri ve inClass durumları
    var studentsList: [(name: String, inClass: Bool)] = [] // Öğrenci bilgilerini tutacak (isim ve inClass durumu)

    @IBAction func logoutButtontapped(_ sender: UIButton) {
        logout()
    }
    func logout() {
        do {
                    try Auth.auth().signOut()
                    print("Başarıyla çıkış yapıldı.")
                    
                    // Welcome Page'e yönlendirme
                    
if let welcomeVC = storyboard?.instantiateViewController(withIdentifier: "WelcomePage") { // WelcomePageVC ID'sini değiştirin
                        welcomeVC.modalPresentationStyle = .fullScreen
                        welcomeVC.modalTransitionStyle = .crossDissolve
                        present(welcomeVC, animated: true, completion: nil)
                    }
                } catch let error {
                    print("Çıkış yapılamadı: \(error.localizedDescription)")
                    let alert = UIAlertController(title: "Hata", message: "Çıkış yapılamadı. Lütfen tekrar deneyin.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Kullanıcının UID'sini al ve öğretmen olup olmadığını kontrol et
        guard let teacherUID = Auth.auth().currentUser?.uid else {
            print("Giriş yapan kullanıcı bulunamadı.")
            return
        }

        // Kullanıcının öğretmen olup olmadığını kontrol et
        database.child("teachers").child(teacherUID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("Giriş yapan öğretmen: \(teacherUID)")
                self.loadStudentsInClass() // Öğrencileri yükleme fonksiyonunu çağır
            } else {
                print("Giriş yapan kullanıcı öğretmen değil.")
                let alert = UIAlertController(title: "Hata", message: "Bu ekran yalnızca öğretmenler içindir.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }
        

        tableView.delegate = self
        tableView.dataSource = self
    }

    func loadStudentsInClass() {
        // Öğrenci düğümündeki tüm öğrencileri al
        database.child("students").observeSingleEvent(of: .value) { snapshot in
            if let students = snapshot.value as? [String: [String: Any]] {
                self.studentsInClass.removeAll()
                self.studentsList.removeAll() // Listeyi sıfırla
                for (studentUID, studentData) in students {
                    if let inClass = studentData["inClass"] as? Bool {
                        self.studentsInClass[studentUID] = inClass
                    }
                }
                self.loadStudentDetails()
            }
        }
    }

    func loadStudentDetails() {
        for (studentUID, _) in studentsInClass {
            database.child("students").child(studentUID).observeSingleEvent(of: .value) { snapshot in
                if let studentData = snapshot.value as? [String: Any],
                   let name = studentData["name"] as? String,  // Öğrenci adı
                   let inClass = studentData["inClass"] as? Bool {
                    
                    self.studentsList.append((name, inClass))

                    // TableView'ı güncelle
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("Veri alınamadı veya format hatası.")
                }
            }
        }
    }

    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        let student = studentsList[indexPath.row]
        cell.textLabel?.text = student.name // Öğrencinin adı
        cell.detailTextLabel?.text = student.inClass ? "Here" : "Not Here" // Öğrencinin sınıfta olup olmadığını belirt
        
        return cell
    }
    
    //------------------------------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = studentsList[indexPath.row]
        let studentName = student.name

        // Uyarı penceresi oluştur
        let alert = UIAlertController(title: "Yoklama Güncelle", message: "\(studentName) için yoklama durumu seçin:", preferredStyle: .alert)

        // "Here" seçeneği
        alert.addAction(UIAlertAction(title: "Here", style: .default, handler: { _ in
            self.updateAttendance(for: indexPath.row, to: true)
        }))

        // "Not Here" seçeneği
        alert.addAction(UIAlertAction(title: "Not Here", style: .default, handler: { _ in
            self.updateAttendance(for: indexPath.row, to: false)
        }))

        // İptal seçeneği
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))

        // Uyarı penceresini göster
        self.present(alert, animated: true, completion: nil)
    }

    func updateAttendance(for index: Int, to inClass: Bool) {
        // Öğrencinin UID'sini bulmak için index'i kullanın
        let studentName = studentsList[index].name
        let studentUID = studentsInClass.first { $0.key == studentName }?.key

        guard let validStudentUID = studentUID else {
            print("Student UID not found for name: \(studentName)")
            return
        }

        // Firebase'deki veriyi güncelle
        database.child("students").child(validStudentUID).updateChildValues(["inClass": inClass]) { error, _ in
            if let error = error {
                print("Error updating attendance: \(error.localizedDescription)")
            } else {
                print("Attendance updated for student \(validStudentUID).")
            }
        }

        // Yerel listeyi güncelle
        studentsList[index].inClass = inClass

        // TableView'ı yenile
        tableView.reloadData()
    }

    //------------------------------------

    @IBAction func resetAttendance(_ sender: UIButton) {
        // Öğrencilerin 'inClass' durumunu sıfırla
        for (studentUID, _) in studentsInClass {
            database.child("students").child(studentUID).updateChildValues(["inClass": false]) { error, _ in
                if let error = error {
                    print("Error resetting attendance: \(error.localizedDescription)")
                } else {
                    print("Attendance reset for student \(studentUID).")
                }
            }
        }

        // Bilgilendirme mesajı göster
        let alert = UIAlertController(title: "Başarılı", message: "Yoklama sıfırlandı.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

        // Öğrencilerin bilgilerini yeniden yükle
        loadStudentsInClass()
    }
    
}

*/



/*
import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class teacherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let database = Database.database().reference()
    
    var studentsInClass: [String: Bool] = [:] // Öğrencilerin UID'leri ve inClass durumları
    var studentsList: [(name: String, inClass: Bool)] = [] // Öğrenci bilgilerini tutacak (isim ve inClass durumu)

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let teacherUID = Auth.auth().currentUser?.uid else {
                print("Giriş yapan kullanıcı bulunamadı.")
                return
            }

            // Kullanıcının öğretmen olup olmadığını kontrol edin
            database.child("teachers").child(teacherUID).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    print("Giriş yapan öğretmen: \(teacherUID)")
                    self.loadStudentsInClass()
                } else {
                    print("Giriş yapan kullanıcı öğretmen değil.")
                }
            }
        
        
        // TableView delegate ve dataSource ayarı
        tableView.delegate = self
        tableView.dataSource = self
    }
    func loadStudentsInClass() {
        // Öğrenci düğümündeki tüm öğrencileri al
        database.child("students").observeSingleEvent(of: .value) { snapshot in
            if let students = snapshot.value as? [String: [String: Any]] {
                self.studentsInClass.removeAll()
                for (studentUID, studentData) in students {
                    if let inClass = studentData["inClass"] as? Bool {
                        self.studentsInClass[studentUID] = inClass
                    }
                }
                self.loadStudentDetails()
            }
        }
    }

    /* func loadStudentsInClass(for teacherUID: String) {
        // Öğretmenin sınıfındaki öğrenci UID'lerini al
        database.child("teacher").child(teacherUID).child("students").observeSingleEvent(of: .value) { snapshot in
            if let students = snapshot.value as? [String: Bool] {
                self.studentsInClass = students
                self.loadStudentDetails()
            }
        }
    }
    */
    func loadStudentDetails() {
        for (studentUID, _) in studentsInClass {
            database.child("students").child(studentUID).observeSingleEvent(of: .value) { snapshot in
                if let studentData = snapshot.value as? [String: Any],
                   let name = studentData["name"] as? String,  // Öğrenci adı
                   let inClass = studentData["inClass"] as? Bool {
                    
                    // Öğrencinin verilerini konsola yazdırarak kontrol et
                    print("Student Name: \(name), In Class: \(inClass)")

                    self.studentsList.append((name, inClass))
                    
                    // TableView'ı güncelle
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    print("Veri alınamadı veya format hatası.")
                }
            }
        }
    }
    
    // TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        
        let student = studentsList[indexPath.row]
        cell.textLabel?.text = student.name // Öğrencinin adı
        cell.detailTextLabel?.text = student.inClass ? "Here" : "Not Here" // Öğrencinin sınıfta olup olmadığını belirt
        
        return cell
    }
    
    @IBAction func resetAttendance(_ sender: UIButton) {
        let teacherUID = Auth.auth().currentUser?.uid  // Tek öğretmen olduğundan öğretmenin UID'sini sabitliyoruz

                // Öğrencilerin 'inClass' durumunu sıfırla
                for (studentUID, _) in studentsInClass {
                    database.child("students").child(studentUID).updateChildValues(["inClass": false]) { error, _ in
                        if let error = error {
                            print("Error resetting attendance: \(error.localizedDescription)")
                        } else {
                            print("Attendance reset for student \(studentUID).")
                        }
                    }
                }
                
                // Öğrencilerin bilgilerini yeniden yükleyin
                loadStudentsInClass()
                
                // Bilgilendirme mesajı göster
                let alert = UIAlertController(title: "Başarılı", message: "Yoklama sıfırlandı.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
    }
    
}
*/

/*
 import Foundation
 import UIKit
 import FirebaseAuth
 import FirebaseDatabase

 class teacherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

     let database = Database.database().reference()
     
     var studentsList: [(email: String, inClass: Bool)] = [] // Öğrenci bilgilerini tutacak
     
     @IBOutlet weak var tableView: UITableView!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // Öğretmenin UID'si (tek bir öğretmen olduğu için sabit değer alabilir)
         let teacherUID = "teacherUID123"
         
         // Öğrenci bilgilerini yükle
         loadStudentsInClass(for: teacherUID)
         
         // TableView delegate ve dataSource ayarı
         tableView.delegate = self
         tableView.dataSource = self
     }
     
     func loadStudentsInClass(for teacherUID: String) {
         // Öğretmenin sınıfındaki öğrenci UID'lerini al
         database.child("teacher").child(teacherUID).child("students").observeSingleEvent(of: .value) { snapshot in
             guard let students = snapshot.value as? [String: Bool] else {
                 print("No students found for teacher.")
                 return
             }
             
             // Öğrenci detaylarını topluca al
             self.database.child("users").observeSingleEvent(of: .value) { userSnapshot in
                 guard let allUsers = userSnapshot.value as? [String: [String: Any]] else {
                     print("No users found.")
                     return
                 }
                 
                 for (studentUID, _) in students {
                     if let studentData = allUsers[studentUID],
                        let email = studentData["email"] as? String,
                        let inClass = studentData["inClass"] as? Bool {
                         self.studentsList.append((email, inClass))
                     }
                 }
                 
                 // TableView'ı güncelle
                 DispatchQueue.main.async {
                     self.tableView.reloadData()
                 }
             }
         }
     }
     
     // TableView DataSource Methods
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return studentsList.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
         
         let student = studentsList[indexPath.row]
         cell.textLabel?.text = student.email
         cell.detailTextLabel?.text = student.inClass ? "In Class" : "Not in Class"
         
         return cell
     }
 }

 */
