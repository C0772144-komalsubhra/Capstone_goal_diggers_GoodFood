//
//  ViewController.swift
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

class LoginViewController: UIViewController {
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtpassword: UITextField!
    
    @IBOutlet weak var switchRememberme: UISwitch!
    
    
    @IBOutlet weak var signUpBtn: UIBarButtonItem!
    
    @IBOutlet weak var logBtnLbl: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        Utilities.styleTextField(txtUsername)
        Utilities.styleTextField(txtpassword)
        
//        Utilities.styleFilledButton(logBtnLbl)
        Utilities.styleHollowButton(logBtnLbl)
        
        let ud = UserDefaults.standard
               let e = ud.string(forKey: "email")
               let p = ud.string(forKey: "password")
               
               if let em = e {
                   txtUsername.text = "\(em)"
               }
               
               if let pa = p {
                   txtpassword.text = "\(pa)"
               }
        
        
    }

    @IBAction func btnLogin(_ sender: Any) {

                 guard let email = txtUsername.text, let password = txtpassword.text else { return }
                    signIn(email: email, pass: password) {[weak self] (success) in
                     guard let `self` = self else { return }
                     var message: String = ""
                     if (success) {
                    
                        if(email.contains("goodfood")){
                            if self.switchRememberme.isOn
                                     {
                                        self.setUserDefaults(email: email, password: password)
                                      }else
                                      {
                                        self.removeUserDefaults()
                                      }
                                 message = "welcome User"
                            let agentViewController = self.storyboard?.instantiateViewController(identifier: "resturantVC") as? ResturantViewController
                            self.navigationController?.pushViewController(agentViewController!, animated: true)

                            
                        }else{
                            if self.switchRememberme.isOn
                                                        {
                                                            self.setUserDefaults(email: email, password: password)
                                                        }else
                                                        {
                                                            self.removeUserDefaults()
                                                        }

                        message = "welcome!"
                        let homeViewController = self.storyboard?.instantiateViewController(identifier: "userVC") as? UserHomeViewController
                     self.navigationController?.pushViewController(homeViewController!, animated: true)
                      
                        }
                        
                     } else {
                         message = "please check username or password."
                     }
        //             let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        //             alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        //             self.present(alertController, animated: true)
                }
                
        
    }
    
    func setUserDefaults(email: String, password: String){

           UserDefaults.standard.set(email, forKey: "email")
           UserDefaults.standard.set(password, forKey: "password")
           
           let ud = UserDefaults.standard
           let email = ud.string(forKey: "email")
             self.txtUsername.text = email
           let password = ud.string(forKey: "password")
             self.txtpassword.text = password
       }
       
       func removeUserDefaults(){
           UserDefaults.standard.removeObject(forKey: "email")
             UserDefaults.standard.removeObject(forKey: "password")
           self.txtUsername.text = ""
           self.txtpassword.text = ""
       }
       
    func signIn(email: String, pass: String, completionBlock: @escaping (_ success: Bool) -> Void) {
          Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
              if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                  completionBlock(false)
              } else {
                  completionBlock(true)
              }
          }
      }
}

