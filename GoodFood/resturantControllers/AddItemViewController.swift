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
import FirebaseStorage




class AddItemViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var txtitemName: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtdescription: UITextView!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var imgitem: UIImageView!
    
    var resturantName: String?
    
    
    @IBOutlet weak var addBtnLbl: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
//        Utilities.styleTextField(txtitemName)
//        Utilities.styleTextField(txtCategory)
//        Utilities.styleTextField(txtCost)
        
        
        Utilities.styleFilledButton(addBtnLbl)
        
        imgitem.isUserInteractionEnabled = true
        imgitem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectimage)))
     
    
    }
    
    @objc func selectimage(){
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)


            guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
            }
           
        imgitem.image = image
            // print out the image size as a test
            print(image.size)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAddItem(_ sender: Any) {
    
       
        
    
        
    
       
       

        if let itemname = txtitemName.text, let category = txtCategory.text    {

            let  rn = resturantName!
    

          
            let ref = Storage.storage().reference().child(rn.lowercased()).child(category).child(itemname)
                             
                let uploaddata = self.imgitem.image?.jpegData(compressionQuality: 0.5)
                             
                             let md = StorageMetadata()
                             md.contentType = "image/png"
                              ref.putData(uploaddata! , metadata: nil) { (metadata, error) in
                                  if error == nil {
                                      ref.downloadURL(completion: { (url, error) in
                                 
                                        let durl = String(describing: url!)
                                        //  print("Done, url is \(String(describing: url))")
                                        self.additem(url: durl)
                                      })
                                  }else{
                                      print("error \(String(describing: error))")
                                  }
                              }
            
            

        }
    
        
    }

    private func additem(url: String){
        
         if let itemname = txtitemName.text, let category = txtCategory.text , let description = txtdescription.text, let cost = txtCost.text  {

                let  rn = resturantName!
        
         let db = FirebaseFirestore.Firestore.firestore()
                db.collection("restaurants").document(rn.lowercased()).collection("menu").document(itemname.lowercased()).setData([
                                "itemName":itemname,
                                "category" : category,
                                "description" : description,
                                "cost" : cost,
                                "url" : url
                            ])
        
        
            self.dismiss(animated: true)
            let message = "item Added"
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true)
            self.clearallfields()
       
        }
        
        
    }

    
    func clearallfields(){
        txtitemName.text = ""
        txtCategory.text = ""
        txtdescription.text = ""
        txtCost.text = ""
        
        
    }
    
 
    
}
