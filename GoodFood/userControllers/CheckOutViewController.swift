//
//  CheckOutViewController.swift
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
import Stripe

class CheckOutViewController: UIViewController, STPAddCardViewControllerDelegate{
    
    
    
    @IBOutlet weak var detailstext: UITextView!
    @IBOutlet weak var totalCost: UILabel!
    @IBOutlet weak var cartTable: UITableView!
    
     var selectedRestaurant : String?
     var cartItems = [String]()
     var costs = [Int]()
    var quantity = [Int]()
    var total: Int = 0
      let currentUser = (Auth.auth().currentUser?.uid)!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        populateTableView()
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "clear cart", style: .plain, target: self, action: #selector(addTapped))
   
        
    }
    

    @objc func addTapped(){
            
       
        for item in cartItems
        {
        let itemref = Firestore.firestore().collection("users").document(self.currentUser).collection("cart").document(item)

                    itemref.delete() { err in
                  if let err = err {
                      print("Error removing document: \(err)")
                  } else {
                      print("Document successfully removed!")
                  }
                    }
            
        }
                cartItems.removeAll()
               costs.removeAll()
               quantity.removeAll()
        
        self.cartTable.reloadData()
        self.totalCost.text = ""
      }
  func populateTableView(){
     
            
    let db = Firestore.firestore().collection("users").document(self.currentUser).collection("cart")
            db.getDocuments { (querySnapshot, error) in
                if error != nil{
                    return
                }
                else{
                    
                    
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            
                            self.cartItems.append(doc.documentID)
                            print(doc.get("cost")!)
                            self.costs.append((doc.get("cost")! as! Int) * (doc.get("quantity")! as! Int))
                             self.quantity.append(doc.get("quantity")! as! Int)
                           
                            //  var i1 : Item
                           // i1 = Item(itemName: doc.documentID, price: Double, quantity: <#T##Int#>)
                        }
                        
                    }
                }
                
               print(self.costs)
                
                for cost in self.costs{
                    
                    self.total =   self.total + cost
                }
                
                self.totalCost.text = " Total cost : \(String(self.total))"
                self.cartTable.reloadData()
              
            }
            
            
            
        }
    
    @IBAction func btnPlaceOrder(_ sender: Any) {
        
        let db = FirebaseFirestore.Firestore.firestore()
        
        let orderid = NSUUID().uuidString
        
        db.collection("restaurants").document(selectedRestaurant!.lowercased()).collection("foodorders").document(orderid).setData([
            "itemNames":self.cartItems,
            "quantites" : self.quantity,
            "total": String(self.total),
            "userid": self.currentUser,
            "orderid": orderid
           
        ])
        
        db.collection("users").document(self.currentUser).collection("orders").document(orderid).setData([
                   "itemNames":self.cartItems,
                   "quantites" : self.quantity,
                   "total": String(self.total),
                   "orderid": self.currentUser,
                    "userid": self.currentUser,
                  
               ])
        
        let alertController = UIAlertController(title: nil, message: "Order Placed", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                    self.present(alertController, animated: true)
    }
    
        
    
    @IBAction func btnPopView(_ sender: Any) {
//        let popupVc = (self.storyboard?.instantiateViewController(identifier: "showPopUpId"))! as paymentViewController
//        self.addChild(popupVc)
//        popupVc.view.frame = self.view.frame
//        self.view.addSubview(popupVc.view)
//        popupVc.didMove(toParent: self)
        
        // Setup add card view controller
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        // Dismiss add card view controller
        dismiss(animated: true)
    }
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
         self.dismiss(animated: true)

        print("Printing Strip response:\( paymentMethod.alipay)\n\n")


               detailstext.text = "Printing Strip response:\(paymentMethod.allResponseFields)\n\n"


    }
    
  
    
    
//    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
//
//        print(completion)
//        self.dismiss(animated: true)
//
//        print("Printing Strip response:\(token.allResponseFields)\n\n")
//        print("Printing Strip Token:\(token.tokenId)")
//
//        detailstext.text = "Transaction success! \n\nHere is the Token: \(token.tokenId)\nCard Type: \(token.card!.funding.rawValue)\n\nSend this token or detail to your backend server to complete this payment."
//
//
//    }
    
}

extension CheckOutViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "checkOutCartCell") as! checkOutCartCell
          cell.checkoutlabel.text = " \(cartItems[indexPath.row] ) * \(quantity[indexPath.row]) =  \(costs[indexPath.row])"
          return cell
          
      }
    
    
}
