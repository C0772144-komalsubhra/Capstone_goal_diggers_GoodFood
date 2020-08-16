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

class bookTableViewController: UIViewController {
  
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var selectedRestaurant: String?
    var username = "empty"
    
    @IBOutlet weak var txtNoOfTables: UITextField!
    @IBOutlet weak var lblAvailableTables: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        populatedata()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Route", style: .plain, target: self, action: #selector(addTapped))
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
