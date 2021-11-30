//
//  LoginViewController.swift
//  douxChat
//
//  Created by Seydoux on 2021/11/29.
//

import UIKit
import RxSwift
import RxCocoa
import AWSCognitoAuthPlugin
import Amplify
import GoogleSignIn
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInGoogle: UIButton!
    @IBOutlet weak var signInAppleView: UIStackView!
    
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("loaded")
        self.initView()
        self.setUpSignInApple()
        self.formValidation()
    }
    
    func initView() {
        self.idField.placeholder = "email"
        self.pwField.placeholder = "password"
        self.idField.delegate = self
        self.pwField.delegate = self
        self.signInButton.tag = 0
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func setUpSignInApple() {
        let authButton = ASAuthorizationAppleIDButton()
        authButton.addTarget(self, action: #selector(handleAuthorization), for: .touchUpInside)
        self.signInAppleView.addArrangedSubview(authButton)
    }
    @objc func handleAuthorization() {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email]
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    func formValidation() {
        let idText = idField.rx.text.orEmpty.map(emailValidation)
        let pwText = pwField.rx.text.orEmpty.map(pwValidation)
        
        Observable.combineLatest(idText, pwText, resultSelector: { $0 && $1 })
            .subscribe(onNext: { v in
                if v {
                    self.signInButton.setTitle("로그인", for: .normal)
                    self.signInButton.tag = 1
                } else {
                    self.signInButton.setTitle("회원가입", for: .normal)
                    self.signInButton.tag = 0
                }
            }).disposed(by: disposebag)
    }
    
    func emailValidation(_ email: String) -> Bool {
        return email.count > 0
    }
    
    func pwValidation(_ password: String) -> Bool {
        return password.count > 0
    }
    @IBAction func signInPressed(_ sender: UIButton) {
        print(sender.tag)
        switch sender.tag {
        case 1:
            // show signIn Screen
            Amplify.Auth.signIn(username: idField.text!, password: pwField.text!) { result in
                print("result: ", result)
                switch result {
                case .success(let suc):
                    print("success: ", suc)
                    
                    self.forwardScreen()
                    
                case .failure(let error):
                    print("login Failed: ", error)
                }
            }
        case 0:
            // show signUp Screen
            guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { return }
            signUpVC.delegate = self
            self.present(signUpVC, animated: true, completion: nil)
            
        default: break
        }
    }
    @IBAction func googleLoginPressed(_ sender: UIButton) {
    }
    
    private func forwardScreen() {
        DispatchQueue.main.async {
            guard let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
            
            chatVC.modalPresentationStyle = .fullScreen
            self.present(chatVC, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let userEmail = appleIdCredential.email
            let fullName = appleIdCredential.fullName
            print("11 credential: ", userIdentifier, userEmail, fullName)
            
            self.forwardScreen()
            
        default: break
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error during login with appleID: ", error.localizedDescription)
    }
}

extension LoginViewController: FillLoginForm {
    func fillEmail(email: String) {
        print("asdfasdfasdf", email)
        self.idField.text = email
    }
}

extension LoginViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -300
    }
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    @objc func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}
