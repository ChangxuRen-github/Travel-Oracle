//
//  WelcomeView.swift
//  CS5520-Traverl-Oracle
//
//  Created by Changxu Ren on 11/18/23.
//

import UIKit

class WelcomeView: UIView {
    // image height
    let IMAGE_HEIGHT = CGFloat(300)
    // image width
    let IMAGE_WIDTH = CGFloat(300)
    
    // welcome page image
    var welcomeImage: UIImageView!
    // welcome page label
    var welcomeLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUIComponents()
        initConstraints()
    }
    
    func setupUIComponents() {
        welcomeImage = UIElementUtil.createAndAddLogoImageView(to: self, imageName: "LogoImage1")
        welcomeLabel = UIElementUtil.createAndAddLabel(to: self, text: "Welcome to Travel Oracle", fontSize: Constants.FONT_REGULAR, isCenterAligned: true, isBold: true, textColor: .black)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            welcomeImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            welcomeImage.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            welcomeImage.widthAnchor.constraint(equalToConstant: IMAGE_WIDTH),
            welcomeImage.heightAnchor.constraint(equalToConstant: IMAGE_HEIGHT),
        
            welcomeLabel.topAnchor.constraint(equalTo: welcomeImage.bottomAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            welcomeLabel.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            welcomeLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            welcomeLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
