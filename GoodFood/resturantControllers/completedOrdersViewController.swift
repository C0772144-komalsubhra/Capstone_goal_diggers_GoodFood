//
//  completedOrdersViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-12.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore

class completedOrdersViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    var resturantName: String?
    var completedOrdersArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let rn = resturantName
            let db = Firestore.firestore().collection("restaurants").document((rn?.lowercased())!).collection("completedOrders")
                   db.getDocuments { (querySnapshot, error) in
                       if error != nil{
                           print(error!)
                           return
                       }
                       else{
                           
                           
                           if let snapshotDocuments = querySnapshot?.documents{
                               
                               for doc in snapshotDocuments{
                                   
                        
                                 self.completedOrdersArray.append(doc.documentID)

                                   
                               }
                               
                           }
                       }
                       
                    print(self.completedOrdersArray)
                    
                    self.table.reloadData()
                   }
       
        
    }
    

   

}
extension completedOrdersViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.completedOrdersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comOrdersCell" , for: indexPath)
        cell.textLabel?.text = self.completedOrdersArray[indexPath.row]
        return cell
    }
    



}
