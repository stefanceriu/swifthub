//
//  AuthService.swift
//  swifthub
//
//  Created by Stefan Ceriu on 23/04/2020.
//  Copyright © 2020 Stefan Ceriu. All rights reserved.
//

import UIKit
import Alamofire
import AuthenticationServices

private let oauthAuthorizationEndpoint = "https://github.com/login/oauth/authorize"
private let oauthAccessTokenEndpoint = "https://github.com/login/oauth/access_token"

let oauthClientID = <#T##oauthClientID#>
let oauthClientSecret = <#T##oauthClientSecret#>

private let clientIdParameterName = "client_id"
private let clientSecretParameterName = "client_secret"
private let stateParameterName = "state"
private let temporaryCodeParameterName = "code"
private let accessTokenParameterName = "access_token"

enum AuthServiceError: Error {
    case clientError(String)
    case invalidResponse(String)
}

class AuthService {
    
    private let requestDispatcher: Session
    private var accessTokenRequest: DataRequest?
    private var webAutenticationSession: ASWebAuthenticationSession?
    
    init(requestDispatcher: Session) {
        self.requestDispatcher = requestDispatcher
    }
    
    func requestLogin(presentationContextProvider: ASWebAuthenticationPresentationContextProviding, result: @escaping (Result<String, AuthServiceError>) -> Void) {
    
        guard self.webAutenticationSession == nil && self.accessTokenRequest == nil else {
            print("Already processing request, ignoring.")
            return
        }
        
        let stateUUID = UUID().uuidString
        
        var authURLComponents = URLComponents(string: oauthAuthorizationEndpoint)
        authURLComponents?.queryItems = [URLQueryItem(name: clientIdParameterName, value: oauthClientID),
                                         URLQueryItem(name: stateParameterName, value: stateUUID)]
        
        guard let authURL = authURLComponents?.url! else {
            result(.failure(AuthServiceError.clientError("Could not build authentication url, aborting.")))
            return
        }
    
        self.webAutenticationSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme:"" , completionHandler: { [weak self] (redirectURL, error) in
            
            defer {
                self?.webAutenticationSession = nil
            }
            
            guard error == nil else {
                result(.failure(AuthServiceError.invalidResponse("Failed processing authentication request with error: \(String(describing: error))")))
                return
            }
            
            guard redirectURL != nil else {
                result(.failure(AuthServiceError.invalidResponse("Invalid redirect URL, aborting.")))
                return
            }
            
            guard let redirectURLComponents = NSURLComponents(url: redirectURL!, resolvingAgainstBaseURL: false) else {
                result(.failure(AuthServiceError.invalidResponse("Could not parse redirect, aborting.")))
                return
            }
            
            guard let redirectStateUUID = redirectURLComponents.queryItems?.first(where: { $0.name == stateParameterName })?.value else {
                result(.failure(AuthServiceError.invalidResponse("Invalid redirect state value, aborting.")))
                return
            }
            
            guard redirectStateUUID == stateUUID else {
                result(.failure(AuthServiceError.invalidResponse("State values don't match, aborting.")))
                return
            }
            
            guard let temporaryCode = redirectURLComponents.queryItems?.first(where: { $0.name == temporaryCodeParameterName })?.value else {
                result(.failure(AuthServiceError.invalidResponse("Did not receive temporary code in redirect, aborting.")))
                return
            }
            
            self?.requestAccessToken(stateUUID: stateUUID, temporaryCode: temporaryCode, result: result)
        })
        
        self.webAutenticationSession?.presentationContextProvider = presentationContextProvider
        
        self.webAutenticationSession?.start()
    }
    
    private func requestAccessToken(stateUUID: String, temporaryCode: String, result:@escaping(Result<String, AuthServiceError>) -> Void) {
        
        defer {
            self.accessTokenRequest = nil
        }
        
        let parameters = [temporaryCodeParameterName: temporaryCode,
                          stateParameterName: stateUUID,
                          clientIdParameterName: oauthClientID,
                          clientSecretParameterName: oauthClientSecret]
        
        self.accessTokenRequest = self.requestDispatcher.request(oauthAccessTokenEndpoint, method: .post, parameters: parameters, headers: ["Accept": "application/json"]).responseJSON(completionHandler: { (response) in
            switch(response.result) {
            case .success(let value):
                
                guard let json = value as? [String: Any] else {
                    result(.failure(AuthServiceError.invalidResponse("Could not decode response json, aborting.")))
                    return
                }
                
                guard case let accessToken as String = json.first(where: { $0.key == accessTokenParameterName })?.value else {
                    result(.failure(AuthServiceError.invalidResponse("Invalid access token, aborting.")))
                    return
                }
                
                result(.success(accessToken))
                
            case .failure(let error):
                result(.failure(AuthServiceError.invalidResponse(error.localizedDescription)))
            }
        })
    }
}
