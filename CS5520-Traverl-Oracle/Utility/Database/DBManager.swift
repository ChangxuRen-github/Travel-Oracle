//
//  DBManager.swift
//  CS5520-Traverl-Oracle
//
//  Created by Changxu Ren on 11/18/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

final class DBManager {
    // Constants
    let CONVERSATIONS_COLLECTION = "Conversations"
    let MESSAGES_SUBCOLLECTION = "Messages"
    let USER_COLLECTION = "Users"
    let STORE_COLLECTION = "Stores"
    let REVIEWS_SUBCOLLECTION = "Reviews"
    let USER_PROFILE_IMAGE = "UserProfileImages"
    let CONVERSATION_IMAGES = "ConversationImages"
    let STORE_IMAGES = "StoreImages"
    
    // A public share dbManager instance
    public static let dbManager = DBManager()
    
    // Maintain a reference to the database
    public let database = Firestore.firestore()
    
    // Maintain a reference to firebase storage
    public let storage = Storage.storage()

}

// MARK: - User management
extension DBManager {
    // Add a new user to the database
    public func addUser(with user: User, profileImage: UIImage, completion: @escaping (Bool) -> Void) {
        uploadProfileImage(profileImage, userId: user.uid) { result in
            switch result {
            case .success(let imageUrl):
                var updatedUser = user
                updatedUser.profileImageURL = imageUrl

                do {
                    try self.database.collection(self.USER_COLLECTION).document(user.uid).setData(from: updatedUser) { error in
                        if let error = error {
                            print("Error: writing user to firestore failed with \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error: writing user to firestore failed with \(error)")
                    completion(false)
                }

            case .failure(let error):
                print("Error: Uploading image failed with \(error)")
                completion(false)
            }
        }
    }
    
    // Update user profile's display name and profile image
    public func updateUser(user: User, profileImage: UIImage, completion: @escaping (Bool) -> Void) {
        uploadProfileImage(profileImage, userId: user.uid) { result in
            switch result {
            case .success(let imageUrl):
                var updatedUser = user
                updatedUser.profileImageURL = imageUrl

                // Update the user data in Firestore
                do {
                    try self.database.collection(self.USER_COLLECTION).document(user.uid).setData(from: updatedUser, merge: true) { error in
                        if let error = error {
                            print("Error: updating user in Firestore failed with \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } catch let error {
                    print("Error: updating user in Firestore failed with \(error)")
                    completion(false)
                }

            case .failure(let error):
                print("Error: Uploading profile image failed with \(error)")
                completion(false)
            }
        }
    }
    
    // Get profile detail from the database
    public func getUser(withUID uid: String, completion: @escaping (Result<User, Error>) -> Void) {
        database
            .collection(USER_COLLECTION)
            .document(uid)
            .getDocument { (document, error) in
                if let error = error {
                    // If there's an error, pass it to the completion handler
                    completion(.failure(error))
                } else {
                    do {
                        if let user = try document?.data(as: User.self) {
                            // Success, pass the user to the completion handler
                            completion(.success(user))
                        } else {
                            // Document exists but couldn't be parsed into a User
                            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document is not in the correct format"])
                            completion(.failure(error))
                        }
                    } catch {
                        // If there's an error during the conversion, pass it to the completion handler
                        completion(.failure(error))
                    }
                }
            }
    }
    
    // Get all users
    public func getUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        database.collection(USER_COLLECTION).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var users = [User]()
                
                // Iterate through each document in the snapshot
                for document in querySnapshot!.documents {
                    do {
                        // Directly try to decode the document into User
                        let user = try document.data(as: User.self)
                        users.append(user)
                    } catch {
                        // Handle any errors in conversion
                        print("DBManager: error occured when mapping data to User model.")
                        completion(.failure(error))
                        return
                    }
                }
                print("Inside get users: users are \(users)")
                completion(.success(users))
            }
        }
    }
}

// MARK: - Conversation management
extension DBManager {

    // 1. Get all conversations given a list of conversation IDs
    public func getConversations(conversationIds: [String], completion: @escaping (Result<[Conversation], Error>) -> Void) {
        let group = DispatchGroup()
        var conversations = [Conversation]()
        var overallError: Error?

        for id in conversationIds {
            group.enter()
            database.collection(CONVERSATIONS_COLLECTION).document(id).getDocument { (document, error) in
                defer { group.leave() }
                if let error = error {
                    overallError = error
                } else if let document = document, let conversation = try? document.data(as: Conversation.self) {
                    conversations.append(conversation)
                }
            }
        }

        group.notify(queue: .main) {
            if let error = overallError {
                completion(.failure(error))
            } else {
                completion(.success(conversations))
            }
        }
    }
    
    // get conversation between two users
    // return an existing conversation otherwise create a new one
    public func getConversationBetween(with thisUser: User, with thatUser: User, completion: @escaping (Result<Conversation, Error>) -> Void) {
        getConversations(conversationIds: thisUser.conversationIds) { result in
            switch result {
            case .success(let conversations):
                // Check if a conversation with thatUser already exists
                if let existingConversation = conversations.first(where: { $0.participantIds.contains(thatUser.uid) }) {
                    // Return the existing conversation
                    completion(.success(existingConversation))
                } else {
                    // No existing conversation found, create a new one
                    self.createConversationBetween(creatorId: thisUser.uid, participantId: thatUser.uid) { newConversationResult in
                        switch newConversationResult {
                        case .success(let newConversation):
                            // Return the new conversation
                            completion(.success(newConversation))
                        case .failure(let error):
                            // Handle error in creating new conversation
                            completion(.failure(error))
                        }
                    }
                }

            case .failure(let error):
                print("Error: get conversation betwen two users failed.")
                completion(.failure(error))
            }
        }
    }

    // Get all messages given a conversation ID
    public func getMessages(conversationId: String, completion: @escaping (Result<[MessageDAO], Error>) -> Void) {
        database.collection(CONVERSATIONS_COLLECTION).document(conversationId).collection(MESSAGES_SUBCOLLECTION).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let documents = snapshot?.documents {
                let messages = documents.compactMap { try? $0.data(as: MessageDAO.self) }
                completion(.success(messages))
            }
        }
    }
    
    // Create a new conversation
    public func createConversationBetween(creatorId: String, participantId: String, completion: @escaping (Result<Conversation, Error>) -> Void) {
        // a UUID for the conversation
        let conversationUUID = UUID().uuidString
        
        database.runTransaction({ (transaction, errorPointer) -> Any? in
            // reference to the new conversation document with custom UUID
            let newConversationRef = self.database.collection(self.CONVERSATIONS_COLLECTION).document(conversationUUID)
            
            // create a new conversation object
            let newConversation = Conversation(uuid: conversationUUID, createdBy: creatorId, participantIds: [creatorId, participantId])
            
            // serialize and set the new conversation data
            do {
                try transaction.setData(from: newConversation, forDocument: newConversationRef)
            } catch let serializeError {
                errorPointer?.pointee = serializeError as NSError
                return nil
            }
            
            // reference to the user documents
            let creatorRef = self.database.collection(self.USER_COLLECTION).document(creatorId)
            let participantRef = self.database.collection(self.USER_COLLECTION).document(participantId)
            
            // Add the new conversationId to both users' conversationIds array
            transaction.updateData(["conversationIds": FieldValue.arrayUnion([conversationUUID])], forDocument: creatorRef)
            transaction.updateData(["conversationIds": FieldValue.arrayUnion([conversationUUID])], forDocument: participantRef)
            
            return newConversation
        }) { (transactionResult, error) in
            if let error = error {
                completion(.failure(error))
            } else if let conversation = transactionResult as? Conversation {
                completion(.success(conversation))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction failed without an error."])))
            }
        }
    }

    // create a new message given a conversation ID
    public func addMessage(conversationId: String, message: MessageDAO, completion: @escaping (Bool) -> Void) {
        let conversationRef = database.collection(CONVERSATIONS_COLLECTION).document(conversationId)
        let newMessageRef = conversationRef.collection(MESSAGES_SUBCOLLECTION).document() // message.uuid will be generated by firestore
        
        database.runTransaction({ (transaction, errorPointer) -> Any? in
            var newMessage = message
            newMessage.uuid = newMessageRef.documentID
            
            // Serialize and set the new message data
            do {
                try transaction.setData(from: newMessage, forDocument: newMessageRef)
            } catch let serializeError {
                errorPointer?.pointee = serializeError as NSError
                return nil
            }
            
            // Update the last message details in the conversation
            var conversationUpdate: [String: Any] = ["lastMessageText": message.content]
            if let timestamp = message.timestamp {
                conversationUpdate["lastMessageTimestamp"] = timestamp
            } else {
                conversationUpdate["lastMessageTimestamp"] = FieldValue.serverTimestamp()
            }
            transaction.updateData(conversationUpdate, forDocument: conversationRef)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Failed to execute transaction to add a new message: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // create a new image message
    public func addImageMessage(conversationId: String, message: MessageDAO, image: UIImage, completion: @escaping (Bool) -> Void) {
         uploadMessageImage(image) { [weak self] uploadResult in
             switch uploadResult {
             case .success(let url):
                 // Create a new message with the image URL
                 var newMessage = message
                 newMessage.imageURL = url
                 self?.addMessage(conversationId: conversationId, message: newMessage, completion: completion)
             case .failure(let error):
                 print("Error: Uploading message image failed with \(error)")
                 completion(false)
             }
         }
     }
    
    // Add a new conversationId to a user's conversationIds array
    // TODO: not sure if this is still needed. Consider remove it before release. C.Ren
    public func addConversationIdToUser(userId: String, conversationId: String, completion: @escaping (Bool) -> Void) {
        let userRef = database.collection(USER_COLLECTION).document(userId)

        userRef.updateData([
            "conversationIds": FieldValue.arrayUnion([conversationId])
        ]) { error in
            if let error = error {
                print("Error adding new conversationId to user: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

// MARK: - Store management
extension DBManager {
    // Add a new store
    public func addStore(with store: Store, with images: [UIImage], completion: @escaping (Result<Store, Error>) -> Void) {
        var store = store
        let dispatchGroup = DispatchGroup()
        var imageUrls = [String]()
        
        for image in images {
            dispatchGroup.enter()
            uploadStoreImages(image: image) { result in
                switch result {
                case .success(let url):
                    imageUrls.append(url)
                case .failure(let error):
                    completion(.failure(error))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            store.images = imageUrls
            self.addStore(store: store, completion: completion)
        }
    }
    
    private func addStore(store: Store, completion: @escaping (Result<Store, Error>) -> Void) {
        do {
            try self.database.collection(self.STORE_COLLECTION).document(store.id).setData(from: store) { error in
                if let error = error {
                    print("Error: writing store to firestore failed with \(error)")
                    completion(.failure(error))
                } else {
                    completion(.success(store))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // Upload store images
    private func uploadStoreImages(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 80) {
            let storageRef = storage.reference()
            let imagesRepo = storageRef.child(STORE_IMAGES)
            let imageRef = imagesRepo.child("\(UUID().uuidString).jpg")
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
    
    // Fetch all stores with a given category
    public func fetchStoresByCategory(_ category: String, completion: @escaping (Result<[Store], Error>) -> Void) {
        database.collection(STORE_COLLECTION)
                .whereField("category", isEqualTo: category)
                .getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var stores: [Store] = []
                querySnapshot?.documents.forEach { document in
                    if let store = try? document.data(as: Store.self) {
                        stores.append(store)
                    } else {
                        print("Error decoding a store document")
                    }
                }
                completion(.success(stores))
            }
        }
    }
    
    // Fetch all stores
    public func fetchAllStores(completion: @escaping (Result<[Store], Error>) -> Void) {
        database.collection(STORE_COLLECTION).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                var stores: [Store] = []
                querySnapshot?.documents.forEach { document in
                    if let store = try? document.data(as: Store.self) {
                        stores.append(store)
                    } else {
                        print("Error decoding a store document")
                    }
                }
                completion(.success(stores))
            }
        }
    }
    
    // Fetch all saved stores
    public func fetchSavedStores(for user: User, completion: @escaping (Result<[Store], Error>) -> Void) {
        let savedStoreIds = user.savedStoreIds
        guard !savedStoreIds.isEmpty else {
            completion(.success([]))
            return
        }
        let group = DispatchGroup()
        var stores = [Store]()
        var overallError: Error?
        for storeId in savedStoreIds {
            group.enter()
            database.collection(STORE_COLLECTION).document(storeId).getDocument { (document, error) in
                defer { group.leave() }
                if let error = error {
                    overallError = error
                } else if let document = document, let store = try? document.data(as: Store.self) {
                    stores.append(store)
                }
            }
        }
        group.notify(queue: .main) {
            if let error = overallError {
                completion(.failure(error))
            } else {
                completion(.success(stores))
            }
        }
    }
    
    // Method to add a storeId to a user's savedStoreIds
    public func addStoreToSaved(for userId: String, storeId: String, completion: @escaping (Bool) -> Void) {
        // Fetch the user from Firestore
        database.collection(USER_COLLECTION).document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(false)
                return
            }

            do {
                var user = try document?.data(as: User.self)
                // Add the storeId to savedStoreIds if not already present
                if !(user?.savedStoreIds.contains(storeId) ?? false) {
                    user?.savedStoreIds.append(storeId)
                    try self.database.collection(self.USER_COLLECTION).document(userId).setData(from: user, merge: true) { error in
                        if let error = error {
                            print("Error adding storeId to savedStoreIds: \(error)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                } else {
                    completion(true) // Store ID already in savedStoreIds
                }
            } catch {
                print("Error decoding user or updating Firestore: \(error)")
                completion(false)
            }
        }
    }

    // Method to remove a storeId from a user's savedStoreIds
    public func removeStoreFromSaved(for userId: String, storeId: String, completion: @escaping (Bool) -> Void) {
        // Fetch the user from Firestore
        database.collection(USER_COLLECTION).document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(false)
                return
            }

            do {
                var user = try document?.data(as: User.self)
                // Remove the storeId from savedStoreIds if present
                user?.savedStoreIds.removeAll(where: { $0 == storeId })
                try self.database.collection(self.USER_COLLECTION).document(userId).setData(from: user, merge: true) { error in
                    if let error = error {
                        print("Error removing storeId from savedStoreIds: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } catch {
                print("Error decoding user or updating Firestore: \(error)")
                completion(false)
            }
        }
    }
}

// MARK: - Review management
extension DBManager {
    // add a new review to store
    public func addNewReview(with review: Review, with store: Store, completion: @escaping (Bool) -> Void) {
        let storeRef = database.collection(STORE_COLLECTION).document(store.id)
        let newReviewRef = storeRef.collection(REVIEWS_SUBCOLLECTION).document() // uuid and timestamp will be generated by firestore
        do {
            try newReviewRef.setData(from: review) { error in
                if let error = error {
                    print("Error adding review: \(error)")
                    completion(false)
                } else {
                    print("Review successfully added")
                    completion(true)
                }
            }
        } catch let error {
            print("Error writing review to Firestore: \(error)")
            completion(false)
        }
    }
}

// MARK: - firebase storage: image management
extension DBManager {
    private func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 80) {
            let storageRef = storage.reference()
            let imagesRepo = storageRef.child(USER_PROFILE_IMAGE)
            let imageRef = imagesRepo.child("\(userId).jpg")
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
    
    public func fetchProfileImage(fromURL urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(UIImage(systemName: "person.circle")) // Return default image if URL is invalid
            return
        }

        // Create a data task to fetch the image data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching image: \(error)")
                    completion(UIImage(systemName: "person.circle")) // Return default image on error
                } else if let data = data, let image = UIImage(data: data) {
                    completion(image) // Return the fetched image
                } else {
                    completion(UIImage(systemName: "person.circle")) // Return default image if no data or unable to create image
                }
            }
        }
        task.resume()
    }
    
    private func uploadMessageImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 80) {
            let storageRef = storage.reference()
            let imagesRepo = storageRef.child(CONVERSATION_IMAGES)
            let imageRef = imagesRepo.child("\(NSUUID().uuidString).jpg")
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }
}
