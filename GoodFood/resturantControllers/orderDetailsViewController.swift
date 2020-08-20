//
//  orderDetailsViewController.swift
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

class orderDetailsViewController: UIViewController {
    @IBOutlet weak var detailsLabel: UITextView!
    
    @IBOutlet weak var totalCostLbl: UILabel!
    var orderID : String?
    var selectedRestaurant: String?
    var orderArray = [String:Any]()
     var itemsArray = [String]()
    var i : Int = 0
  var quantityArray = [Int]()
  


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        getItems()
        
    }
    

    func getItems(){
           
               let sr = selectedRestaurant!
            //   let oi = orderID!
           let db = Firestore.firestore().collection("restaurants").document(sr).collection("foodorders")
           
           db.getDocuments() { (querySnapshot, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                   } else {
                       for document in querySnapshot!.documents {
                          // print("\(document.documentID) => \(document.data())")
                           self.orderArray = document.data()
                        self.itemsArray = self.orderArray["itemNames"] as! [String]
                        self.quantityArray = self.orderArray["quantites"] as! [Int]
                        
                        repeat {
                            self.detailsLabel.text = self.detailsLabel.text + "\n" + " item: \(self.itemsArray[self.i]) \n quantity : \(self.quantityArray[self.i])"
                     
                            self.i += 1
                        } while self.i < self.quantityArray.count
                      
                    
                        let  total = self.orderArray["total"]
                        self.totalCostLbl.text = total as? String
                           
                           
                       }
                   }
           }
           
           
       }
    
    func addToCompletedTask(){
        let sr = selectedRestaurant!
               let oi = orderID!
             var data: Any?
             
             let db = Firestore.firestore().collection("restaurants").document(sr).collection("foodorders").whereField("orderid", isEqualTo: oi)
             
                    db.getDocuments { (querySnapshot, error) in
                                        if error != nil{
                                            print(error!)
                                            return
                                        }
                                        else{
                                            
                                           
                                            
                                            if let snapshotDocuments = querySnapshot?.documents{
                                              
                                             
                                                for doc in snapshotDocuments{
                                     
                                                    
                                                 data = doc.data()
                 //                                   self.ordersArray.append(doc.documentID)
                 //                                   self.orderID = doc.documentID
                                             
                                                    let db = Firestore.firestore().collection("restaurants").document(sr).collection("completedOrders").document(oi)
                                                    db.setData(data as! [String : Any])
                                                }
                                                
                                            }
                                        }
                     
                                        
                                    }
        
        
    }
    
    
    
    @IBAction func btnCompleteOrder(_ sender: Any) {
        
       
            addToCompletedTask()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sr = self.selectedRestaurant!
            let oi = self.orderID!
        let itemref = Firestore.firestore().collection("restaurants").document(sr).collection("foodorders").document(oi)

            itemref.delete() { err in
          if let err = err {
              print("Error removing document: \(err)")
          } else {
              print("Document successfully removed!")
          }
            }

        let alertController = UIAlertController(title: nil, message: "order completed", preferredStyle: .alert)
                                           alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                               self.navigationController?.popViewController(animated: true)
                                           }))
                                           self.present(alertController, animated: true)

        }
        
    }
    
       
}
