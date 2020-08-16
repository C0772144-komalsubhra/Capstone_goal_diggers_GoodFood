//
//  DetailedItemViewController.swift
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

class DetailedItemViewController: UIViewController {

    @IBOutlet weak var itemDetails: UITextView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    @IBOutlet weak var itemQuantity: UILabel!
    
    var selectedItem: String?
    var selectedRestaurant : String?
    var itemDict: [String : Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getItems()
    }
    
     func getItems(){
        
            let sr = selectedRestaurant!
            let si = selectedItem!
        let db = Firestore.firestore().collection("restaurants").document(sr).collection("menu").whereField("itemName", isEqualTo: si)
        
        db.getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.itemDict = document.data()
                        print(self.itemDict)
                        self.itemDetails.text = (self.itemDict["description"] as! String)
                        self.itemCost.text = (self.itemDict["cost"] as! String)
                         self.itemName.text = si
                        
                        
                    }
                }
        }
        
        
    }
    

    @IBAction func addToCart(_ sender: Any) {
         if(itemQuantity.text! != "0"){
        let currentUser = (Auth.auth().currentUser?.uid)!
          let db = FirebaseFirestore.Firestore.firestore()
        let cost = Int((self.itemDict["cost"] as! String))! * 1

            db.collection("users").document(currentUser).collection("cart").document(self.selectedItem!).setData(["quantity": Int(itemQuantity.text!)! , "cost": cost])
        
        let alertController = UIAlertController(title: nil, message: "item Added", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                        self.navigationController?.popViewController(animated: true)
                                    }))
                                    self.present(alertController, animated: true)
         }else{
            let alertController = UIAlertController(title: nil, message: "please select quantity", preferredStyle: .alert)
                                               alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                               self.present(alertController, animated: true)
            
        }
        
    }
    
    
    @IBAction func btnremove(_ sender: Any) {
        if(itemQuantity.text! != "0"){
      let value = Int(itemQuantity.text!)
           itemQuantity.text = String(  value! - 1)
        }
    }
    
    
    @IBAction func btnadd(_ sender: Any) {
        
        let value = Int(itemQuantity.text!)
        itemQuantity.text = String(  value! + 1)
    }
    
}
