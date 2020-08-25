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
import Stripe
protocol getstatusdelegate{
    func getstatus(data: String)
}

class paymentViewController: UIViewController, STPAddCardViewControllerDelegate {
    
    @IBOutlet weak var paybtnoutlet: UIButton!
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "place"), object: nil)
        
        self.dismiss(animated: true)
        self.removeAnimate()
        
        
    }
    
    
    
    
    
    
    @IBOutlet weak var phoneNumberLabel: UITextField!
    
    @IBOutlet weak var otpLabel: UITextField!
    var delegate: getstatusdelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.showAnimate()
      paybtnoutlet.isHidden = true
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
                self.paybtnoutlet.isHidden = false
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
    
    @IBAction func btnpay(_ sender: Any) {
        
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
        
        
        func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
            // Dismiss add card view controller
            dismiss(animated: true)
        }
        
        
        
    }
    
    
    
    
}
