//
//  SaveScreenView.swift
//  CS5520-Traverl-Oracle
//
//  Created by XIN JIN on 12/3/23.
//

import UIKit

class SavedStoreView: UIView {

    var tableView: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupTableView()
        initConstraints()
    }
    
    func setupTableView(){
        tableView = UITableView()
        tableView.register(SavedStoreScreenTableViewCell.self, forCellReuseIdentifier: SavedStoreScreenTableViewCell.IDENTIFIER)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        self.addSubview(tableView)
    }
    
    //MARK: setting the constraints...
    func initConstraints(){
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            tableView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
