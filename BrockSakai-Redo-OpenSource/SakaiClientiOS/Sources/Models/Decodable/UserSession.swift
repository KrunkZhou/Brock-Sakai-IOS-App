//
//  UserSession.swift
//  SakaiClientiOS
//
//  Created by Pranay Neelagiri on 8/31/18.
//  Modified by Krunk
//

import Foundation

/// The model for a User's session used to validate a user's authentication
struct UserSession {
    let userEid: String
}

extension UserSession: Decodable {}
