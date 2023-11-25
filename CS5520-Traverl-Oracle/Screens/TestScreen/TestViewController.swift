//
//  TestViewController.swift
//  CS5520-Traverl-Oracle
//
//  Created by Changxu Ren on 11/24/23.
//

import UIKit

class TestViewController: UIViewController {
    
    let testView = TestView()
    
    let childProgressView = ProgressSpinnerViewController()
    
    var sfSymbols: [String]!
    var imageArray: [UIImage]!

    override func viewDidLoad() {
        super.viewDidLoad()
        addTargetToButtons()
        setupSampleImageArray()
    }

    override func loadView() {
        view = testView
    }
    
    func setupSampleImageArray() {
        // Define an array of SF Symbols names
        sfSymbols = ["house.fill", "car.fill", "leaf.fill"]
        // Create UIImage array from SF Symbols
        imageArray = sfSymbols.compactMap { UIImage(systemName: $0) }
    }
    
    // sample store
    let sampleStore = Store(
        id: UUID().uuidString, // unique identifier
        createdAt: nil, // will be set on the server side
        createdBy: "user123", // example user ID
        displayName: "My Sample Store",
        description: "This is a sample store description.",
        price: "$$",
        category: "Cafe",
        images: [], // initially empty, will be filled after image upload
        tag: Tag(
            price: "$",
            goodForBreakfast: "Yes",
            goodForLunch: "Yes",
            goodForDinner: "No",
            takesReservations: "No",
            vegetarianFriendly: "Yes",
            cuisine: "Italian",
            liveMusic: "No",
            outdoorSeating: "Yes",
            freeWIFI: "Yes"
        )
    )
}

// - Action listener
extension TestViewController {
    func addTargetToButtons() {
        testView.testSaveStoreButton.addTarget(self,
                                               action: #selector(onTestSaveStoreButtonTapped),
                                               for: .touchUpInside)
    }
    
    @objc func onTestSaveStoreButtonTapped() {
        print("Test Save Store Button Tapped.")
        self.showActivityIndicator()
        DBManager.dbManager.addStore(with: sampleStore, with: imageArray) { result in
            self.hideActivityIndicator()
            switch result {
            case .success(let store):
                print("Store added successfully: \(store)")
            case .failure(let error):
                print("Error adding store: \(error)")
            }
        }
    }
}

// - Spinner
extension TestViewController: ProgressSpinnerDelegate {
    func showActivityIndicator() {
        addChild(childProgressView)
        view.addSubview(childProgressView.view)
        childProgressView.didMove(toParent: self)
    }
    
    func hideActivityIndicator() {
        childProgressView.willMove(toParent: nil)
        childProgressView.view.removeFromSuperview()
        childProgressView.removeFromParent()
    }
}