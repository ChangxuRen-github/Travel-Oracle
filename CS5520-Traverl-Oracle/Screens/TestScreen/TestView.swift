//
//  TestView.swift
//  CS5520-Traverl-Oracle
//
//  Created by Changxu Ren on 11/24/23.
//

import UIKit

class TestView: UIView {
    var contentWrapper: UIScrollView!
    
    var testSaveStoreButton: UIButton!
    
    var testStoreDetailScreenButton: UIButton!
    
    var testSavedStoreScreenButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUIComponents()
        initConstraints()
    }
    
    func setupUIComponents() {
        contentWrapper = UIElementUtil.createAndAddScrollView(to: self)
        testSaveStoreButton = UIElementUtil.createAndAddButton(to: contentWrapper,
                                                               title: "Save Test Store",
                                                               color: .black,
                                                               titleColor: .white)
        testStoreDetailScreenButton = UIElementUtil.createAndAddButton(to: contentWrapper,
                                                               title: "Go to store detail screen",
                                                               color: .black,
                                                               titleColor: .white)
        testSavedStoreScreenButton = UIElementUtil.createAndAddButton(to: contentWrapper,
                                                                      title: "Go to saved store screen",
                                                                      color: .black,
                                                                      titleColor: .white)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            contentWrapper.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            contentWrapper.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            contentWrapper.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor),
            contentWrapper.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor),
            
            testSaveStoreButton.topAnchor.constraint(equalTo: contentWrapper.topAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            testSaveStoreButton.centerXAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.centerXAnchor),
            testSaveStoreButton.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            testSaveStoreButton.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            
            testStoreDetailScreenButton.topAnchor.constraint(equalTo: testSaveStoreButton.bottomAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            testStoreDetailScreenButton.centerXAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.centerXAnchor),
            testStoreDetailScreenButton.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            testStoreDetailScreenButton.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            
            testSavedStoreScreenButton.topAnchor.constraint(equalTo: testStoreDetailScreenButton.bottomAnchor, constant: Constants.VERTICAL_MARGIN_LARGE),
            testSavedStoreScreenButton.centerXAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.centerXAnchor),
            testSavedStoreScreenButton.leadingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.leadingAnchor, constant: Constants.HORIZONTAL_MARGIN_REGULAR),
            testSavedStoreScreenButton.trailingAnchor.constraint(equalTo: contentWrapper.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.HORIZONTAL_MARGIN_REGULAR),
            
            testSavedStoreScreenButton.bottomAnchor.constraint(equalTo: contentWrapper.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
