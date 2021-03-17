//
//  LoginViewController.swift
//  chat_App
//
//  Created by JoSoJeong on 2021/02/05.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    
    private let scollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true //scroll 둥글게
        return scrollView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none // 중앙 정렬
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Emamil Address ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    

    private let passwdField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none // 중앙 정렬
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .green
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
   
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let faceBookloginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        
        return button
    }()
    
    private let googleloginButton = GIDSignInButton()
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ///notificationCenter singleton pattern
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue:.main, using: { [weak self] _ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        view.backgroundColor = .white
        
        title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRigRegister))
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        //add subviews
        view.addSubview(scollView)
        scollView.addSubview(imageView)
        scollView.addSubview(emailField)
        scollView.addSubview(passwdField)
        scollView.addSubview(loginButton)
        scollView.addSubview(faceBookloginButton)
        scollView.addSubview(googleloginButton)
        
        emailField.delegate = self
        passwdField.delegate = self
        faceBookloginButton.delegate = self
        
        loginButton.center = view.center
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scollView.frame = view.bounds
        let size = scollView.width/3
        imageView.frame = CGRect(x: (scollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scollView.width - 60, height: 52)
        passwdField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwdField.bottom + 20, width: scollView.width - 60, height: 52)
        faceBookloginButton.frame = CGRect(x: 30, y: loginButton.bottom + 30, width: scollView.width - 60, height: 52)
        googleloginButton.frame = CGRect(x: 30, y: faceBookloginButton.bottom + 30, width: scollView.width - 60, height: 52)
    }
    
    
    @objc private func didTapRigRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwdField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwdField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        spinner.show(in: view)
        
        //firebase Log in
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else{
            print("failed to log in user with email : \(email)")
            return
        }
            
        let user = result.user
        UserDefaults.standard.set(email, forKey: "email")
        
        strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to login", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == emailField){
            passwdField.becomeFirstResponder()
        }else if(textField == passwdField){
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error{
            print("error error : " , error.localizedDescription)
            return
        }
        
        
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let faceBookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, firstt_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        faceBookRequest.start(completionHandler:  { _, result, error in
            
            guard let result = result as? [String: Any],
                  error == nil else {
                print("Failed to make facebook grah request")
                return
            }
            
            print("\(result)")
            guard let firstName = result["first_name"] as? String,
            let lastName = result["last_name"] as? String,
            let email = result["email"] as? String,
            let picture = result["picture"] as? [String: Any],
            let data = picture["data"] as? [String: Any],
            let pictureUrl = data["url"] as? String else {
                print("Faield to get email and name from fb result")
                return
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            
        
            DatabaseManager.shared.userExits(with: email, completion: { exists in
                if !exists {
                    
                    let chatUser = chatAppUSer(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    
                    DatabaseManager.shared.insertUSer(with: chatUser, completion: {success in
                    if success{
                    //upload image
                        guard let url = URL(string: pictureUrl) else {
                            return
                        }

                        print("Downloading data from facebook image")

                       URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                           guard let data = data else {
                               print("Failed to get data from facebook")
                               return
                           }

                           print("got data from FB, uploading...")

                           // upload iamge
                           let filename = chatUser.profilePictureFileName
                        StorageManager.shared.uplaodProfilePicture(with: data, fileName: filename, completion: { result in
                               switch result {
                               case .success(let downloadUrl):
                                   UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                   print(downloadUrl)
                               case .failure(let error):
                                   print("Storage maanger error: \(error)")
                               }
                           })
                       }).resume()
                    }
                    })
                    
                }
            })
        
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with:credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, error == nil else{
                    print("Facebook credential login failed MFA may be needed")
                    return
                }
                
                print("successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
       
    }
    
   
}











