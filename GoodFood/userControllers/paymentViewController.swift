//
//  paymentViewController.swift
//  GoodFood
//
//  Created by adithyasai neeli on 2020-08-13.
//  Copyright © 2020 GagandeepKaur. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase
import FirebaseFirestore

class paymentViewController: UIViewController {

    @IBOutlet weak var phoneNumberLabel: UITextField!
    
    @IBOutlet weak var otpLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
          self.showAnimate()
    }
    

    @IBAction func btnSubmit(_ sender: Any) {
        guard let  phoneNumber = phoneNumberLabel.text else {return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
          if let error = error {
          print(error)
            return
          }
            
          UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    @IBAction func btnOtp(_ sender: Any) {
        
         guard let  otpCode = otpLabel.text else {return }
        
      guard  let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {return }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otpCode)
        
        Auth.auth().signIn(with: credential){
            
            (success,error) in if error == nil{
                
                let alertController = UIAlertController(title: nil, message: "successfull", preferredStyle: .alert)
                           alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                           self.present(alertController, animated: true)
                
            }else{
                print("Something went wrong")
            }
        }
    }
    func showAnimate(){
        
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
       {
           UIView.animate(withDuration: 0.25, animations: {
               self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
               self.view.alpha = 0.0;
               }, completion:{(finished : Bool)  in
                   if (finished)
                   {
                       self.view.removeFromSuperview()
                   }
           });
       }
    
    
    @IBAction func btnCancel(_ sender: Any) {
        self.removeAnimate()
        print("remove animate")
    }
    
}
