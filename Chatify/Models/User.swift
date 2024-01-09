//
//  User.swift
//  Chatify
//
//  Created by Amr Mohamad on 20/09/2023.
//

import Foundation
import RealmSwift

struct User {
    var id: String
    var name: String
    var email: String
    var profileImageURL: String
}

class UserRealmObject: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var email: String
    @Persisted var profileImageURL: String

    @Persisted var messages: List<MessageRealmObject>
}
