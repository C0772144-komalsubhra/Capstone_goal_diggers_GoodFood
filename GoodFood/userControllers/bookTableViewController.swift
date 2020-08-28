//
//  bookTableViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-11.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore
import UserNotifications

class bookTableViewController: UIViewController {
  
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var selectedRestaurant: String?
    var username = "empty"
    
    @IBOutlet weak var txtNoOfTables: UITextField!
    @IBOutlet weak var lblAvailableTables: UILabel!
    
    
    @IBOutlet weak var bookTblBtnLbl: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        Utilities.styleTextField(txtNoOfTables)
        Utilities.styleFilledButton(bookTblBtnLbl)
        populatedata()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Route", style: .plain, target: self, action: #selector(addTapped))
        
//        UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
    }
    
    @objc func addTapped(){
        
        if let mapViewController = self.storyboard?.instantiateViewController(identifier: "mapVC") as? mapViewController{
            mapViewController.fromVC = "BookTable"
            mapViewController.selectedRestaurant = self.selectedRestaurant
             self.navigationController?.pushViewController(mapViewController, animated: true)
        }
       }
    
    func populatedata(){
        
        let sr = self.selectedRestaurant
        let db3 = Firestore.firestore().collection("restaurants").document((sr?.lowercased())!).collection("AvailableTables")
        db3.getDocuments { (querySnapshot, error) in
            if error != nil{
                print(error!)
                return
            }
            else{
                
                
                if let snapshotDocuments = querySnapshot?.documents{
                    
                    for doc in snapshotDocuments{
                        
                        let data = doc.data()
                        if let availablecount = data["availabletables"] as? String{
                            
                            self.lblAvailableTables.text = availablecount
                            
                            
                        }
                        
                        
                        
                    }
                    
                }
            }
    
        }
        
        let currentUser = (Auth.auth().currentUser?.uid)!
            let db =  Firestore.firestore().collection("users")
            db.whereField("uuid", isEqualTo: currentUser)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let name = document.get("firstname")
                        self.username = name as! String
                    }
                }
        }
           
               
    }
    
    @IBAction func btnBookTable(_ sender: Any) {
        
        if txtNoOfTables.text == "" {

            let alertController = UIAlertController(title: nil, message: "please select seats", preferredStyle: .alert)
                       alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                       self.present(alertController, animated: true)
            
        }else if dateLabel.text == "Select Date"{
                
                let alertController = UIAlertController(title: nil, message: "please select date", preferredStyle: .alert)
                           alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                           self.present(alertController, animated: true)
                
            }else{
            
            let tablecount = Int( self.lblAvailableTables.text!)! - Int(self.txtNoOfTables.text!)!
            print(tablecount)
            let currentUser = (Auth.auth().currentUser?.uid)!
            let sr = self.selectedRestaurant!
            let db = FirebaseFirestore.Firestore.firestore()
            
            
            db.collection("users").document(currentUser).collection("bookedtables").document(sr).setData(["seats" : self.txtNoOfTables.text! , "name" : self.username , "status" : "Not Confirmed" , "date" : dateLabel.text!])
            
            db.collection("restaurants").document(sr).collection("bookedtables").document(currentUser).setData(["seats" : self.txtNoOfTables.text! , "name" : self.username ,"status" : "Not Confirmed" , "date" : dateLabel.text!  ])
            
            db.collection("restaurants").document(sr).collection("AvailableTables").document("TotalTables").setData([
                "availabletables":  String(tablecount)
            ])
            let alertController = UIAlertController(title: nil, message: "Table Booked", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.navigationController?.popViewController(animated: true)
                
                let center = UNUserNotificationCenter.current()
                                              
                let content = UNMutableNotificationContent()
                content.title = "DoorDoctor Reminder"
//                content.body = "you have booked your appointment with \(dNameLabel.text!) at \(tlabel.text!) on \(dlabel.text!)"
                content.sound = .default
                content.badge = 1
                                       
                let calendar = Calendar.current
                let components = DateComponents(year: 2020, month: 04, day: 22, hour: 17, minute: 00) // Set the date here when you want Notification
                let date = calendar.date(from: components)
                let comp2 = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: date!)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comp2, repeats: false)

                let tigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
                let request = UNNotificationRequest(identifier: "reminder", content: content, trigger: tigger)
                center.add(request) { (error) in
                        print("Erorr =\(error?.localizedDescription ?? "error local notification") " )
                                              }
            }))
            self.present(alertController, animated: true)
                
            }
            
        
        
    }
    
    
    @IBAction func dateChanged(_ sender: Any) {
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short

        let strDate = dateFormatter.string(from: datePicker.date)
        dateLabel.text = strDate
    }
    
}
