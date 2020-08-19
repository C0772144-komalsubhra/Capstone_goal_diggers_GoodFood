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

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var txtFirstName: UITextField!
    
    @IBOutlet weak var txtLastName: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var txtResturantName: UITextField!
    
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnResturant: UIButton!
    
    var clicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hideFields()
        buttoncolors()
        
    }
    
    
    @IBAction func btnUser(_ sender: Any) {
        
        clicked = true
        btnUser.layer.borderColor = UIColor.red.cgColor
        btnResturant.layer.borderColor = UIColor.black.cgColor
        txtFirstName.isHidden = false
        txtLastName.isHidden = false
        txtEmail.isHidden = false
        txtPassword.isHidden = false
        txtAddress.isHidden = false
        txtResturantName.isHidden = true
    }
    
    @IBAction func btnResturant(_ sender: Any) {
        clicked = false
        btnUser.layer.borderColor = UIColor.black.cgColor
        btnResturant.layer.borderColor = UIColor.red.cgColor
        txtFirstName.isHidden = true
        txtLastName.isHidden = true
        txtEmail.isHidden = false
        txtPassword.isHidden = false
        txtAddress.isHidden = false
        txtResturantName.isHidden = false
    }
    
    @IBAction func SignUp(_ sender: Any) {
        
        let error = validateFields()
                     
                     if error == nil {
               
                     if let email = txtEmail.text, let password = txtPassword.text {
                        createUser(email: email, password: password) {[weak self] (success) in
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
    
    
      func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
              Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
                  if let user = authResult?.user {
                      print(user)
                      completionBlock(true)

                      if(self.clicked != true){
                      // Create cleaned versions of the data
                  let ResturantName = self.txtResturantName.text!
                        let address = self.txtAddress.text!
                      
                      let db = FirebaseFirestore.Firestore.firestore()
                        db.collection("restaurants").document(ResturantName.lowercased()).setData(["restaurantname":ResturantName,
                                                                "address":address,
                                                                "ruid": authResult!.user.uid
                        ])
                        
                      self.clearfields()
                      }else{
                          
                                             let firstName = self.txtFirstName.text!
                                             let lastName = self.txtLastName.text!
                                            let address = self.txtAddress.text!
                                             let db = FirebaseFirestore.Firestore.firestore()
                        db.collection("users").document(authResult!.user.uid).setData(["firstname":firstName, "lastname":lastName, "uuid": authResult!.user.uid,  "address":address ])
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
