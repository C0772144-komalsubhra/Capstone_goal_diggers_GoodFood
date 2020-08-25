//
//  placeOrderViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-06.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore
import BadgeSwift

class placeOrderViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var BtnBadge: BadgeSwift!
    var itemArray = [String]()
    var selectedRestaurant : String?
    var imgitemArray = [Any]()
      var itemsdict = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()

        populatecollectionView()
       // print(selectedRestaurant)
        setbadgecount()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
             setbadgecount()
      }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


 func populatecollectionView(){
    
    let sr = selectedRestaurant!
       
    let db = Firestore.firestore().collection("restaurants").document(sr).collection("menu")
       db.getDocuments { (querySnapshot, error) in
           if error != nil{
            print(error!)
               return
           }
           else{
               
               
               if let snapshotDocuments = querySnapshot?.documents{
                
                print(snapshotDocuments.count)
                   for doc in snapshotDocuments{
                   
                    self.itemsdict = doc.data()
                     
                     self.itemArray.append(doc.documentID)
                    self.imgitemArray.append(self.itemsdict["url"]!)
                    
              
                       
                   }
                   
               }
           }
       
          print(self.itemArray)
        self.collectionView.reloadData()
          
       }
       
       
       
   }
    func setbadgecount(){
                 let currentUser = (Auth.auth().currentUser?.uid)!
        let db = Firestore.firestore().collection("users").document(currentUser).collection("cart")
                db.getDocuments { (querySnapshot, error) in
                    if error != nil{
                        return
                    }
                    else{
                        
                        
                       let snapshotDocuments = querySnapshot?.documents
                     
                        self.BtnBadge.text =  String(snapshotDocuments!.count)
                        
                    }
                    
        }
            
        
    }
    
    
    @IBAction func btnViewCart(_ sender: Any) {
        
        if let CheckOutViewController = self.storyboard?.instantiateViewController(identifier: "checkoutVC") as? CheckOutViewController{
                 CheckOutViewController.selectedRestaurant = self.selectedRestaurant
                       self.navigationController?.pushViewController(CheckOutViewController, animated: true)
                   }
         }
    
    
    @IBAction func btnBookTable(_ sender: Any) {
        
        
                if let bookTableViewController = self.storyboard?.instantiateViewController(identifier: "booktableVC") as? bookTableViewController{
                  
                     bookTableViewController.selectedRestaurant = selectedRestaurant
                                       self.navigationController?.pushViewController(bookTableViewController, animated: true)
                                   }
                  }
        
    
    @IBAction func btnLogout(_ sender: Any) {
        
        
        
    }
    
    
}

extension placeOrderViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       //  return 15
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! itemNameCollectionViewCell
     //   cell.label.text = "item"
       cell.label.text = self.itemArray[indexPath.row]
        print(self.imgitemArray[indexPath.row])
        let itemimageurl = self.imgitemArray[indexPath.row]
        let url = URL(string: itemimageurl as! String)
           URLSession.shared.dataTask(with: url!) { (data, response, error) in
               if error != nil{
                   print(error!)
                   return
               }
               
               DispatchQueue.main.async(execute: {

                   cell.imgitem.image = UIImage(data: data!)
                    cell.imgitem.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
                   })
           }.resume()
           
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
         if let DetailedItemViewController = self.storyboard?.instantiateViewController(identifier: "ItemDetailsVC") as? DetailedItemViewController{
            DetailedItemViewController.selectedItem = self.itemArray[indexPath.row]
              DetailedItemViewController.selectedRestaurant = selectedRestaurant
                                self.navigationController?.pushViewController(DetailedItemViewController, animated: true)
                            }
           }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
          let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
          let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
          return CGSize(width: size, height: size)
      
    
    }
   
    
}
