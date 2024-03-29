//
//  ConversationsViewController.swift
//  CS5520-Traverl-Oracle
//
//  Created by Changxu Ren on 11/30/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ConversationsViewController: UIViewController {
    // initialize conversation view
    private let conversationsView = ConversationsView()
    
    // Spinner
    private let childProgressView = ProgressSpinnerViewController()
    
    // current user
    private var thisUser: User!
    
    // firestore listener
    private var conversationsListener: ListenerRegistration?
    
    // initialize conversations array
    var conversations = [Conversation]()
    
    override func loadView() {
        view = conversationsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove separator lines for table view
        conversationsView.conversationsTableView.separatorStyle = .none
        doTableViewDelegations()
        setupNavBar()
        initializeUser()
    }
    
    deinit {
        // clean up listener when view controller is deinitialized
        conversationsListener?.remove()
    }
}

// MARK: - Setups
extension ConversationsViewController {
    func setupNavBar() {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black,
        ]
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        title = "Chats"
    }
    
    func initializeUser() {
        guard let uwUser = AuthManager.shared.currentUser else {
            AlertUtil.showErrorAlert(viewController: self,
                                     title: "Error!",
                                     errorMessage: "Please sign in.")
            self.transitionToLoginScreen()
            return
        }
        DBManager.dbManager.getUser(withUID: uwUser.uid) { [weak self] result in
            switch result {
            case .success(let user):
                self?.thisUser = user
                self?.setupConversationsListener()
            case .failure(let error):
                print("Error fetching user details: \(error)")
            }
        }
    }
    
    func setupConversationsListener() {
        // Set up the listener
        conversationsListener = DBManager.dbManager.database.collection(DBManager.dbManager.CONVERSATIONS_COLLECTION)
            .whereField("participantIds", arrayContains: thisUser.uid)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error getting conversations: \(error)")
                    return
                }
                
                // Handle the document changes
                querySnapshot?.documentChanges.forEach { change in
                    switch change.type {
                    case .added:
                        // Deserialize and add the new Conversation object
                        if let conversation = try? change.document.data(as: Conversation.self) {
                            self.conversations.append(conversation)
                        }
                        
                    case .modified:
                        // Update the existing Conversation object
                        if let conversation = try? change.document.data(as: Conversation.self),
                           let index = self.conversations.firstIndex(where: { $0.uuid == conversation.uuid }) {
                            self.conversations[index] = conversation
                        }
                        
                    case .removed:
                        // Handle conversation removal if necessary
                        break
                    }
                    
                    // TODO: Update UI here, reload the table view -Done
                    self.conversationsView.conversationsTableView.reloadData()
                }
            }
    }
}

// MARK: - Transition between screens
extension ConversationsViewController {
    
    func transitionToLoginScreen() {
        // TODO: clear the stack and add log in screen -Done
        let loginViewController = LoginViewController()
        var viewControllers = self.navigationController!.viewControllers
        viewControllers.removeAll()
        viewControllers.append(loginViewController)
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    func transitionToConversationScreen(with thisUser: User, with thatUser: User, with conversation: Conversation) {
        let conversationViewController = ConversationViewController(with: thisUser, with: thatUser, with: conversation)
        navigationController?.pushViewController(conversationViewController, animated: true)
    }
}

// MARK: - Table views
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    // delegations
    func doTableViewDelegations() {
        conversationsView.conversationsTableView.delegate = self
        conversationsView.conversationsTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationsTableViewCell.IDENTIFIER,
                                                 for: indexPath) as! ConversationsTableViewCell
        let conversationModel = conversations[indexPath.row]
        cell.config(with: conversationModel, with: thisUser)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openConversation(with: conversations[indexPath.row])
    }
    
    func openConversation(with conversation: Conversation) {
        // TODO: transition to Conversation Screen -Done
        self.showActivityIndicator()
        // Iterate the participantIds and find thatUser's uid
        let thatUserId = conversation.participantIds.first(where: {
            $0 != thisUser.uid
        })
        guard let thatUserId = thatUserId else {
            print("Conversation only contains the current user, no other user has been found!")
            return
        }
        // Retrieve User object of thatUser
        DBManager.dbManager.getUser(withUID: thatUserId) { result in
            self.hideActivityIndicator()
            switch result {
            case .success(let thatUser):
                // retrieve that user successful, transition to conversation screen
                self.transitionToConversationScreen(with: self.thisUser, with: thatUser, with: conversation)
            case .failure(let error):
                print("Error retrieving user: \(error.localizedDescription)")
                AlertUtil.showErrorAlert(viewController: self,
                                         title: "Error!",
                                         errorMessage: "Failed to retrieve user with uid \(thatUserId): \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Spinner
extension ConversationsViewController: ProgressSpinnerDelegate {
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
