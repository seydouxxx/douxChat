//
//  ChatViewController.swift
//  douxChat
//
//  Created by Seydoux on 2021/11/29.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("loaded")
        // Do any additional setup after loading the view.
        self.initView()
    }
    private func initView() {
        self.chatTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
}

extension ChatViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ sender: Notification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            print("asdf: ", keyboardFrame.cgRectValue.height)
            self.view.frame.origin.y = -keyboardFrame.cgRectValue.height + view.safeAreaInsets.bottom - 10
            print("1: ", self.view.frame.origin.y)
        }
    }
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
        print("2: ", self.view.frame.origin.y)
    }
    @objc func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
