//
//  LoginView.swift
//  CS5520-Traverl-Oracle
//
//  Created by dongjun xie on 11/18/23.
//

import UIKit

class LoginView: UIView {

    // image height
    let IMAGE_HEIGHT = CGFloat(200)
    // image width
    let IMAGE_WIDTH = CGFloat(200)
    
    var contentWrapper: UIScrollView!
    var loginImage: UIImageView!
    var loginButton: UIButton!
    var emailTextField: UITextField!
    var passwordTextField: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUIComponents()
        initConstraints()
    }
    
    func setupUIComponents() {
        contentWrapper = UIElementUtil.createAndAddScrollView(to: self)
        loginImage = UIElementUtil.createAndAddLogoImageView(to: contentWrapper, imageName: "LogoImage2")
        emailTextField = UIElementUtil.createAndAddTextField(to: contentWrapper, placeHolder: "Email", keyboardType: .emailAddress)
        passwordTextField = UIElementUtil.createAndAddTextField(to: contentWrapper, placeHolder: "Password", keyboardType: .default)
        passwordTextField.isSecureTextEntry = true // set password to secure text entry
        loginButton = UIElementUtil.createAndAddButton(to: contentWrapper, title: "Log In", color: UIColor(hexString: "#b34538"), titleColor: .white)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            contentWrapper.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            contentWrapper.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            contentWrapper.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor),
            contentWrapper.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor),
            
            loginImage.topAnchor.constraint(equalTo: contentWrapper.topAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            loginImage.centerXAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.centerXAnchor),
            loginImage.widthAnchor.constraint(equalToConstant: IMAGE_WIDTH),
            loginImage.heightAnchor.constraint(equalToConstant: IMAGE_HEIGHT),
            
            emailTextField.topAnchor.constraint(equalTo: loginImage.bottomAnchor, constant: Constants.VERTICAL_MARGIN_REGULAR),
            emailTextField.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            emailTextField.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: Constants.VERTICAL_MARGIN_REGULAR),
            passwordTextField.centerXAnchor.constraint(equalTo: contentWrapper.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            passwordTextField.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
        
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            loginButton.centerXAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            loginButton.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            loginButton.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
