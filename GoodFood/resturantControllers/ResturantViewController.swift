//
//  ResturantViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-05.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore

class ResturantViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet weak var lblwelcome: UILabel!
    
    @IBOutlet weak var lblAvailableTables: UILabel!
    
    @IBOutlet weak var ordersSegment: UISegmentedControl!

    @IBOutlet weak var ordersTable: UITableView!
    
    var resturantName: String?
    var orderID = "empty"
    var tableDate = "empty"
    var resname = "empty"
    
    var ordersArray = [String]()
    var bookedTablesArray = [String]()
    var bookedTablesSeats = [String]()
    var customersName = [String]()
    var status = [String]()
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.isHidden = true
        UNUserNotificationCenter.current().delegate = self
        
       // navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        
        
        
    }
    
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//    @objc func logout(){
//          do { try Auth.auth().signOut() }
//        catch { print("already logged out") }
//        navigationController?.popToRootViewController(animated: true)
//    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           navigationController?.setNavigationBarHidden(true, animated: animated)
        populatecollectionView()
        ordersTable.reloadData() 
    }
    
    func populatecollectionView(){
        
        self.ordersArray.removeAll()
        var rn: String?
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments { (querySnapshot, error) in
            if error != nil{
                return
            }
            else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let currentUser = Auth.auth().currentUser?.uid{
                            if let u = data["ruid"] as? String{
                                if u == currentUser{
                                    if let firstname = data["restaurantname"] as? String{
                                        
                                        self.lblwelcome.text = "Hello, \(firstname)"
                                        self.resturantName = firstname
                                        rn = firstname
                                        self.resname = firstname
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                    }}
                
                let db2 = Firestore.firestore().collection("restaurants").document((rn?.lowercased())!).collection("foodorders")
                db2.getDocuments { (querySnapshot, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    else{
                        
                        
                        if let snapshotDocuments = querySnapshot?.documents{
                            
                            for doc in snapshotDocuments{
                                
                                
                                self.ordersArray.append(doc.documentID)
                                self.orderID = doc.documentID
                                
                            }
                            
                        }
                    }
                    
                
                    self.ordersTable.reloadData()
                    
                }
                
                let db3 = Firestore.firestore().collection("restaurants").document((rn?.lowercased())!).collection("AvailableTables")
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
                
                let db4 = Firestore.firestore().collection("restaurants").document((rn?.lowercased())!).collection("bookedtables")
                    db4.getDocuments { (querySnapshot, error) in
                                 if error != nil{
                                     print(error!)
                                     return
                                 }
                                 else{
                                     
                                     
                                     if let snapshotDocuments = querySnapshot?.documents{
                                            self.bookedTablesArray.removeAll()
                                           self.bookedTablesSeats.removeAll()
                                         self.customersName.removeAll()
                                          self.status.removeAll()
                                         for doc in snapshotDocuments{
                                         
                                            self.bookedTablesArray.append(doc.documentID)
                                            self.bookedTablesSeats.append(doc.get("seats") as! String)
                                            self.customersName.append(doc.get("name") as! String)
                                            self.status.append(doc.get("status") as! String)
                                            self.tableDate = doc.get("date") as! String
                                             
                                             
                                             
                                         }
                                         
                                     }
                                    
                                   if( self.bookedTablesArray.count > 0)
                                   {
                                    let notificationContent = UNMutableNotificationContent()
                                                               notificationContent.title = "Table Booking "
                                                               
                                                                    notificationContent.body = "New Table booking added please review"
                                                                    notificationContent.badge = NSNumber(value: 1)
                                                                    
                                                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3,
                                                                                                                    repeats: false)
                                                                    let request = UNNotificationRequest(identifier: "testNotification",
                                                                                                        content: notificationContent,
                                                                                                        trigger: trigger)
                                                                    
                                                               self.userNotificationCenter.add(request) { (error) in
                                                                        if let error = error {
                                                                            print("Notification Error: ", error)
                                                                        }
                                                                    }
                                                               
                                    
                                    
                                    }
                                 }
                                 
                                 
                                 
                             }
                
                
                
            }
        }
        
        
        
        
        
        
        
    }
    @IBAction func btnAddItem(_ sender: Any) {
        
        if let AddItemViewController = self.storyboard?.instantiateViewController(identifier: "addItemVC") as? AddItemViewController{
            AddItemViewController.resturantName = self.resturantName
            self.navigationController?.pushViewController(AddItemViewController, animated: true)
        }
    }
    
    
    
    @IBAction func btnCompletedOrders(_ sender: Any) {
        
        
        if let completedOrdersViewController = self.storyboard?.instantiateViewController(identifier: "completedordersVC") as? completedOrdersViewController{
                  completedOrdersViewController.resturantName = self.resturantName
                  self.navigationController?.pushViewController(completedOrdersViewController, animated: true)
              }
        
    }
    
    
    @IBAction func selectSegment(_ sender: Any) {
        
        switch ordersSegment.selectedSegmentIndex {
                  case 0:
                 print("first segment")
                  case 1:
                     print("second segment")
                  default:
                      break;
                  }
        ordersTable.reloadData()
    }
    
    @IBAction func btnManageTables(_ sender: Any) {
        let ac = UIAlertController(title: "Set Available tables", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]
            self.lblAvailableTables.text = answer.text
            
            // do something interesting with "answer" here
            let db = FirebaseFirestore.Firestore.firestore()
            
            db.collection("restaurants").document(self.resturantName!).collection("AvailableTables").document("TotalTables").setData([
                "availabletables":  answer.text as Any
            ])
        }
        
        ac.addAction(submitAction)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        present(ac, animated: true)
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
               willPresent notification: UNNotification,
               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            completionHandler(.alert)
        }
    
    
    @IBAction func btnlogout(_ sender: Any) {
         do { try Auth.auth().signOut() }
                catch { print("already logged out") }
                navigationController?.popToRootViewController(animated: true)
    }
    
}
extension ResturantViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if self.ordersSegment.selectedSegmentIndex == 0{
        return self.ordersArray.count
          }else{
            return self.customersName.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "restOrderCell") as! restOrderViewCell
        if self.ordersSegment.selectedSegmentIndex == 0{
              cell.label.text =  String(indexPath.row + 1)
            cell.label.textColor = UIColor.systemYellow
             cell.statusLabel.text = ""
                 }else{
                    cell.label.text =  self.customersName[indexPath.row]
                        cell.label.textColor = UIColor.systemYellow
                    cell.statusLabel.text = self.status[indexPath.row]
                            if(status[indexPath.row] == "Not Confirmed"){
                                       cell.statusLabel.textColor = UIColor.red
                            }else{
                                cell.statusLabel.textColor = UIColor.green
            }
               }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           if self.ordersSegment.selectedSegmentIndex == 0{
        if let orderDetailsViewController = self.storyboard?.instantiateViewController(identifier: "orderDetailsVC") as? orderDetailsViewController{
            
            orderDetailsViewController.orderID = self.orderID
            orderDetailsViewController.selectedRestaurant = self.resturantName
            self.navigationController?.pushViewController(orderDetailsViewController, animated: true)
        }
        }else{
           
            let alertController = UIAlertController(title: nil, message: "\(self.bookedTablesSeats[indexPath.row]) seats booked \n \(self.tableDate)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "confirm", style: .default, handler: { action in                let db = Firestore.firestore().collection("restaurants").document((self.resname.lowercased())).collection("bookedtables").document(self.bookedTablesArray[indexPath.row])
               
                db.updateData(["status" : "Confirmed"])
                Firestore.firestore().collection("users").document(self.bookedTablesArray[indexPath.row]).collection("bookedtables").document(self.resname.lowercased()).updateData(["status" : "Confirmed"])
                self.populatecollectionView()
                self.ordersTable.reloadData()
                
            
             }))
            alertController.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
              self.present(alertController, animated: true)
        }
    }
    
    
    
}
