//
//  User.swift
//  CS5520-Traverl-Oracle
//
//  Created by XIN JIN on 11/19/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    let uid: String
    let email: String
    let displayName: String
    // conversations between different users
    var conversationIds: [String]
    // profileImageURL save the url of the image from firebase storage
    var profileImageURL: String?
    // Use the property wrapper for automatic handling
    // If createdAt is nil, Firestore will automatically fill it with the server's current timestamp.
    @ServerTimestamp var createdAt: Date?
    var savedStoreIds: [String]
}
