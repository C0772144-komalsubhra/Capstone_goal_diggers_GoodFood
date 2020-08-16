//
//  AddItemViewController.swift
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

class AddItemViewController: UIViewController {
    
    @IBOutlet weak var txtitemName: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtdescription: UITextView!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var imgitem: UIImageView!
    
    var resturantName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func btnAddItem(_ sender: Any) {
        
        let db = FirebaseFirestore.Firestore.firestore()
        
        if let itemname = txtitemName.text, let category = txtCategory.text , let description = txtdescription.text, let cost = txtCost.text  {
            
            let  rn = resturantName!
        

            db.collection("restaurants").document(rn.lowercased()).collection("menu").document(itemname.lowercased()).setData([
                        "itemName":itemname,
                        "category" : category,
                        "description" : description,
                        "cost" : cost
                    ])
          
            
        }
        let message = "item Added"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
        clearallfields()
        
    }
    
    func clearallfields(){
        txtitemName.text = ""
        txtCategory.text = ""
        txtdescription.text = ""
        txtCost.text = ""
        
        
    }
    
}
