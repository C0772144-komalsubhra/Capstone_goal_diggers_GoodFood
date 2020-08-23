//
//  UserHomeViewController.swift
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

class UserHomeViewController: UIViewController {
    
    @IBOutlet weak var lblWelcome: UILabel!
    
    @IBOutlet weak var menuSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var resarray = [String]()
    var bookedtables = [String]()
    var noOfSeats = "empty"
    var date = "empty"
    var status = [String]()
    var imagesArray = [Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        greetUser()
    
        populateTableView()
     
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
           tablesbooked()
          

      }

    
    func greetUser(){
        
        
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (querySnapshot, error) in
            if error != nil{
                return
            }
            else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        print(data)
                        if let currentUser = Auth.auth().currentUser?.uid{
                            if let u = data["uuid"] as? String{
                                if u == currentUser{
                                    if let firstname = data["firstname"] as? String{
                                        DispatchQueue.main.async {
                                            self.lblWelcome.text = "Hello, \(firstname)"
                                            
                                        }
                                    }
                                    
                                  
                                    
                                }
                            }
                        }
                        
                    }}
            }
        }
        
    }
    func populateTableView(){
        
        let db = Firestore.firestore()
        db.collection("restaurants").getDocuments { (querySnapshot, error) in
            if error != nil{
                return
            }
            else{
                
                
                if let snapshotDocuments = querySnapshot?.documents{
                    
                     
                    for doc in snapshotDocuments{
                         let data = doc.data()
                 
                      
                        self.imagesArray.append(data["url"])
                        self.resarray.append(doc.documentID)
                       
                        print(self.imagesArray)
                        
                    }
                    
                }
            }
            

        self.tableView.reloadData()
        }
        
  
      

            
    }
    
    func tablesbooked(){
        let currentUser = (Auth.auth().currentUser?.uid)!
               let db2 = Firestore.firestore().collection("users").document(currentUser).collection("bookedtables")
                       db2.getDocuments { (querySnapshot, error) in
                           if error != nil{
                               return
                           }
                           else{


                               if let snapshotDocuments = querySnapshot?.documents{
                                   for doc in snapshotDocuments{

                                     
                                    self.bookedtables.removeAll()
                                       self.bookedtables.append(doc.documentID)
                                       print(doc.get("seats")!)
                                    self.noOfSeats.removeAll()
                                        self.noOfSeats = doc.get("seats") as! String
                                    self.status.removeAll()
                                       self.status.append(doc.get("status") as! String)
                                    self.date.removeAll()
                                       self.date  = doc.get("date") as! String

                                   }

                               }
                           }
                        self.tableView.reloadData()
               }
        
        
    }
    @IBAction func segmentChange(_ sender: Any) {
        
        switch menuSegment.selectedSegmentIndex {
           case 0:
          print("first segment")
           case 1:
              print("second segment")
           default:
               break;
           }
        tableView.reloadData()
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        
        do { try Auth.auth().signOut() }
                     catch { print("already logged out") }
                     navigationController?.popToRootViewController(animated: true)
        
    }
    
}

extension UserHomeViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        return 1
       
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        
        if self.menuSegment.selectedSegmentIndex == 0{
     
                 return resarray.count
               }else{
            return bookedtables.count
               }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resturantsNameCell") as! restaurantsNameTableViewcell
       
         cell.img.image = nil
        if self.menuSegment.selectedSegmentIndex == 0{
                       cell.label.text = resarray[indexPath.row]
                           cell.statusLabel.text = ""
            let itemimageurl = self.imagesArray[indexPath.row]
                   let url = URL(string: itemimageurl as! String)
                      URLSession.shared.dataTask(with: url!) { (data, response, error) in
                          if error != nil{
                              print(error!)
                              return
                          }

                          DispatchQueue.main.async(execute: {

                              cell.img.image = UIImage(data: data!)
                            cell.img.frame = CGRect(x: 0, y: 0, width: 50, height:50)

                              })
                      }.resume()
                      }else{
            cell.img.image = UIImage(named: "tableimage")
           //  cell.img.frame = CGRect(x: 0, y: 0, width: 50, height:50)
            
                          cell.label.text = bookedtables[indexPath.row]
                        cell.statusLabel.text = status[indexPath.row]
                        if(status[indexPath.row] == "Not Confirmed"){
                            cell.statusLabel.textColor = UIColor.red
                                }else{
                                                    cell.statusLabel.textColor = UIColor.green
                                }
                     
                      }
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.menuSegment.selectedSegmentIndex == 0{
                              
         if let placeOrderViewController = self.storyboard?.instantiateViewController(identifier: "placeOrderVC") as? placeOrderViewController{
            placeOrderViewController.selectedRestaurant = resarray[indexPath.row]
                         self.navigationController?.pushViewController(placeOrderViewController, animated: true)
                     }
        }else{
            
            let alertController = UIAlertController(title: nil, message: "\(self.noOfSeats) seats booked \n date: \(self.date)", preferredStyle: .alert)
                                               alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                               self.present(alertController, animated: true)
        }
    }
    
    
}
