//
//  SignUpViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-05.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var txtFirstName: UITextField!
    
    @IBOutlet weak var txtLastName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var txtResturantName: UITextField!
    
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnResturant: UIButton!
    
    @IBOutlet weak var userimage: UIImageView!
    
    @IBOutlet weak var signUpBtnLbl: UIButton!
    
    var clicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Utilities.styleHollowButton(btnUser)
        Utilities.styleHollowButton(btnResturant)
        Utilities.styleTextField(txtFirstName)
        Utilities.styleTextField(txtLastName)
        Utilities.styleTextField(txtPassword)
        Utilities.styleTextField(txtEmail)
        Utilities.styleTextField(txtAddress)
        Utilities.styleTextField(txtResturantName)
        Utilities.styleFilledButton(signUpBtnLbl)
        
        
        userimage.isUserInteractionEnabled = true
               userimage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectimage)))
//        hideFields()
//        buttoncolors()
        
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
             
          userimage.image = image
              // print out the image size as a test
              print(image.size)
          
      }
      
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          print("canceled")
          dismiss(animated: true, completion: nil)
      }
    
    @IBAction func btnUser(_ sender: Any) {
        
        clicked = true
        btnUser.layer.borderColor = UIColor.brown.cgColor
        btnResturant.layer.borderColor = UIColor.yellow.cgColor
        txtFirstName.isHidden = false
        txtLastName.isHidden = false
        txtEmail.isHidden = false
        txtPassword.isHidden = false
        txtAddress.isHidden = false
        txtResturantName.isHidden = true
    }
    
    @IBAction func btnResturant(_ sender: Any) {
        clicked = false
        btnUser.layer.borderColor = UIColor.yellow.cgColor
        btnResturant.layer.borderColor = UIColor.brown.cgColor
        txtFirstName.isHidden = true
        txtLastName.isHidden = true
        txtEmail.isHidden = false
        txtPassword.isHidden = false
        txtAddress.isHidden = false
        txtResturantName.isHidden = false
    }
    
    @IBAction func SignUp(_ sender: Any) {
        

       var  ref = Storage.storage().reference().child("profileimages").child(self.txtFirstName.text!)
        let error = validateFields()
                          
                          if error == nil {
                            if(clicked == false){
                              ref = Storage.storage().reference().child("profileimages").child(self.txtResturantName.text!)
                                
                            }
            let uploaddata = self.userimage.image?.jpegData(compressionQuality: 0.5)
                         
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
        
        }else{
                                  
                                  let alertController = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                                      alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                      self.present(alertController, animated: true)
                                  
                          }
     
    }
    
  
    private func additem(url: String){
        
        let error = validateFields()
                          
                          if error == nil {
                    
                          if let email = txtEmail.text, let password = txtPassword.text {
                            createUser(email: email, password: password , url: url) {[weak self] (success) in
                                  guard let `self` = self else { return }
                                  var message: String = ""
                                  if (success) {
                                      message = "User was sucessfully created."
                                 
                                  } else {
                                      message = "There was an error."
                                  }
                                  let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                  alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                  self.present(alertController, animated: true)
                              }
                          }
                          }else{
                            
                            let alertController = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                                self.present(alertController, animated: true)
                            
                    }
        
    }
    
    
    func createUser(email: String, password: String,url: String , completionBlock: @escaping (_ success: Bool) -> Void) {
              Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
                  if let user = authResult?.user {
                      print(user)
                      completionBlock(true)

                      if(self.clicked != true){
                      // Create cleaned versions of the data
                  let ResturantName = self.txtResturantName.text!
                        let address = self.txtAddress.text!
                      
                      let db = FirebaseFirestore.Firestore.firestore()
                        db.collection("restaurants").document(ResturantName.lowercased()).setData(["restaurantname":ResturantName.lowercased(),
                                                                "address":address,
                                                                "ruid": authResult!.user.uid,
                                                                "url": url
                            
                        ])
                        
                      self.clearfields()
                      }else{
                          
                                             let firstName = self.txtFirstName.text!
                                             let lastName = self.txtLastName.text!
                                            let address = self.txtAddress.text!
                                             let db = FirebaseFirestore.Firestore.firestore()
                        db.collection("users").document(authResult!.user.uid).setData(["firstname":firstName, "lastname":lastName, "uuid": authResult!.user.uid,  "address":address , "url": url])
                                             self.clearfields()
                          
                          
                      }
                   
                  } else {
                      completionBlock(false)
                  }
              }
          }
    
    func clearfields(){
        txtFirstName.text?.removeAll()
        txtResturantName.text?.removeAll()
        txtLastName.text?.removeAll()
        txtPassword.text?.removeAll()
        txtAddress.text?.removeAll()
          txtEmail.text?.removeAll()
        
        
        
        
    }
    
    func hideFields()
    {
        txtFirstName.isHidden = true
        txtResturantName.isHidden = true
        txtLastName.isHidden = true
        txtPassword.isHidden = true
        txtAddress.isHidden = true
        txtEmail.isHidden = true
        
        
    }
    func buttoncolors()
    {
        btnUser.backgroundColor = .clear
        btnUser.layer.cornerRadius = 5
        btnUser.layer.borderWidth = 1
        btnUser.layer.borderColor = UIColor.black.cgColor
        
        btnResturant.backgroundColor = .clear
        btnResturant.layer.cornerRadius = 5
        btnResturant.layer.borderWidth = 1
        btnResturant.layer.borderColor = UIColor.black.cgColor
    }
    
    func validateFields() -> String? {
        
        if(clicked != true){
            
                            if txtResturantName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                             txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                             txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                             
                             return "Please fill in all fields."
                         }
      
        }else{
            if txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                      txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                      txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
                      txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                      
                      return "Please fill in all fields."
                  }
            
            
        }
        
        // Check if the password is secure
        let cleanedPassword = txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    @IBAction func setLocation(_ sender: Any) {
        
       
        
     let mapViewController = self.storyboard?.instantiateViewController(identifier: "mapVC") as? mapViewController
        mapViewController?.delegate = self
         mapViewController?.fromVC = "notrc"
        self.navigationController?.pushViewController(mapViewController!, animated: true)
    
        
    }
    
    
    
}



extension SignUpViewController: getcurrDelegate{

    func getLoctxt(data: String) {
        
             print("worked")
            self.txtAddress.text = data
        }
    
   
    
    
}
