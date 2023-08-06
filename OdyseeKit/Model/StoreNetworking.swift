//
//  StoreNetworking.swift
//  
//
//  Created by Alsey Coleman Miller on 8/6/23.
//

import Foundation
import Odysee

internal extension Store {
    
    func loadURLSession() -> URLSession {
        URLSession(configuration: .ephemeral)
    }
}

private extension Store {
    
    func authorizationToken() async throws -> Odysee.AuthorizationToken {
        /*
        guard let user = self.username,
              let token = self[token: user] else {
            self.username = nil
            try await self.tokenKeychain.removeAll()
            throw OdyseeError.authenticationRequired
        }*/
        return nil
    }
}

public extension Store {
    
    /// Fetch Odysee content.
    func fetchContent() async throws -> [String: Content] {
        let token = try await authorizationToken()
        return try await urlSession.fetchContent(authorization: token, server: .production)
    }
}
