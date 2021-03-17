//
//  RegisterViewController.swift
//  chat_App
//
//  Created by JoSoJeong on 2021/02/05.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
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
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none // 중앙 정렬
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "first name ..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none // 중앙 정렬
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "last name ..."
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
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
   
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .lightGray
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = "Log In"
    
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        //add subviews
        view.addSubview(scollView)
        scollView.addSubview(imageView)
        scollView.addSubview(emailField)
        scollView.addSubview(firstNameField)
        scollView.addSubview(lastNameField)
        scollView.addSubview(passwdField)
        scollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangedProfilePic))
        //gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
        emailField.delegate = self
        passwdField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scollView.frame = view.bounds
        let size = scollView.width/3
        imageView.layer.cornerRadius = imageView.width / 2.0
        
        imageView.frame = CGRect(x: (scollView.width - size)/2, y: 20, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: imageView.bottom + 10, width: scollView.width - 60, height: 52)
        firstNameField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: scollView.width - 60, height: 52)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: scollView.width - 60, height: 52)
        passwdField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: scollView.width - 60, height: 52)
        registerButton.frame = CGRect(x: 30, y: passwdField.bottom + 20, width: scollView.width - 60, height: 52)
    }
    
    
    @objc private func didTapChangedProfilePic(){
        presentPhotoActionSheet()
    }
    
    @objc private func registerButtonTapped(){
        emailField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        passwdField.resignFirstResponder()
        
        guard let email = emailField.text, let firstName = firstNameField.text, let lastName = lastNameField.text, let password = passwdField.text,
              !email.isEmpty,!firstName.isEmpty,!lastName.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        //firebase Log in
        DatabaseManager.shared.userExits(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else{
                //user alreay exists
                strongSelf.alertUserLoginError(message:  "Looks like a user account for that email address already exists")
                return
            }
        })
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            
            guard authResult != nil, error == nil else{
                print("Error creating user")
                return
            }
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
            
            let chatUser = chatAppUSer(firstName: firstName, lastName: lastName, emailAddress: email)
            
            DatabaseManager.shared.insertUSer(with: chatUser, completion: {success in
            if success {
            //upload image
                guard let image = self.imageView.image,
                      let data = image.pngData() else {
                    return
                }
                let fileName = chatUser.profilePictureFileName
                StorageManager.shared.uplaodProfilePicture(with: data, fileName: fileName, completion: { result in
                    switch result {
                         case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            print(downloadUrl)
                    case .failure(let error):
                        print("Storage manager error: \(error)")
                    }
                }
                        
                    )}
                
            })

            self.navigationController?.dismiss(animated: true, completion: nil)
        })
        
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create new account"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == emailField){
            passwdField.becomeFirstResponder()
        }else if(textField == passwdField){
            registerButtonTapped()
        }
        return true
    }

}

extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile picture",
                                            message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in self?.presentPhoto()}))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in self?.presentPhoto()}))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhoto(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        self.imageView.image = selectedImage
        //print(info)
        
        //self.imageView
    
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
