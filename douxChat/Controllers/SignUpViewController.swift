//
//  SignUpViewController.swift
//  douxChat
//
//  Created by Seydoux on 2021/11/29.
//

import UIKit
import RxCocoa
import RxSwift
import AWSCognitoAuthPlugin
import Amplify

protocol FillLoginForm: AnyObject {
    func fillEmail(email: String)
}

class SignUpViewController: UIViewController {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    var disposeBag = DisposeBag()
    weak var delegate: FillLoginForm?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("signUpViewLoaded")
        
        self.initView()
        self.formValidation()
    }
    
    private func initView() {
        self.confirmButton.isEnabled = false
    }
    
    private func formValidation() {
        let idText = idField.rx.text.orEmpty.map(emailValidation)
        let pwText = pwField.rx.text.orEmpty.map(pwValidation)
        
        Observable.combineLatest(idText, pwText, resultSelector: { $0 && $1 })
            .subscribe(onNext: { v in
                self.confirmButton.isEnabled = v
            }).disposed(by: disposeBag)
    }
    
    private func emailValidation(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func pwValidation(_ password: String) -> Bool {
        return password.count > 7
    }
    
    private func signUp(username: String, password: String, email: String) {
//        let userAttributes = [AuthUserAttribute(.email, value: email)]
//        print("1 userAttributes: ", userAttributes)
        
//        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password) { result in
            switch result {
            case .success(let signUpResult):
                print("2 signUpResult: ", signUpResult)
                
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("3 Delivery Details :", String(describing: deliveryDetails))
                } else {
                    print("4 SignUp Complete")
                }
                
                // TODO: dismiss view and fill email field
                DispatchQueue.main.async {
                    self.delegate?.fillEmail(email: email)
                    self.dismiss(animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("5 Error in SignUp: ", error)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        self.signUp(username: idField.text!, password: pwField.text!, email: idField.text!)
    }
}
