//
//  EditDomainViewController.swift
//  PBL5
//
//  Created by Minh Quan on 09/06/2023.
//

import UIKit

class EditDomainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textfield.delegate = self
        self.textView.layer.cornerRadius = 8.0
        self.textView.layer.borderColor = UIColor.black.cgColor
        self.textView.layer.borderWidth = 1.0
        self.textfield.text = BASE_DOMAIN
        self.textfield.placeholder = "Your domain"
        self.changeButton.layer.cornerRadius = self.changeButton.frame.height / 2
    }
    
    @IBAction func changeTap(_ sender: UIButton) {
        BASE_DOMAIN = self.textfield.text ?? ""
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
