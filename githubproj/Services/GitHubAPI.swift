//
//  GitHubAPI.swift
//  githubproj
//
//  Created by John Sparks on 1/24/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import OAuthSwift
import SwiftyJSON


struct GithubAPICredentials {
    static let key = "8fc1c2af3e6134cc93ca"
    static let secret = "b55b110c141f4d4698cf446649c6b060b3ce901a"
}

class GithubAPI {
    
    static let shared: GithubAPI = {
        return GithubAPI(key: GithubAPICredentials.key, secret: GithubAPICredentials.secret)
    }()
    
    enum RequestError: String, Error {
        case unauthorized = "Unauthorized"
        case parseError = "ParseError"
    }
    
    let key: String
    let secret: String
    var oauthToken: String?
    let oauth: OAuth2Swift
    var client: OAuthSwiftClient?
    
    init(key: String, secret: String) {
        self.key = key
        self.secret = secret
        self.oauth = OAuth2Swift(
            consumerKey:    key,
            consumerSecret: secret,
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
    }
    
    func authorize(done: @escaping (Error?)->()){
        
        restore()
        
        if client != nil {
            done(nil)
            return
        }
        
        let state = generateState(withLength: 20)
        let _ = oauth.authorize(
            withCallbackURL: URL(string: "beerproject://oauth-callback/github")!,
            scope: "user,repo,write:org",
            state: state,
            success: { credential, response, parameters in
                self.oauthToken = credential.oauthToken
                self.save(token: credential.oauthToken)
                done(nil)
        },
            failure: { error in
                done(error)
        })
    }
    
    func defaultsKey(forItem: String) -> String {
        return "\(key)+\(secret)+\(forItem)"
    }
    
    func save(token: String) {
        UserDefaults.standard.set(token, forKey: defaultsKey(forItem: "oauthToken"))
    }
    
    func restore() {
        if let token = UserDefaults.standard.value(forKey: defaultsKey(forItem: "oauthToken")) as? String {
            client = OAuthSwiftClient(consumerKey: key,
                                      consumerSecret: secret,
                                      oauthToken: token,
                                      oauthTokenSecret: "",
                                      version: .oauth2)
        }
    }
    
    func disconnect() {
        UserDefaults.standard.removeObject(forKey: defaultsKey(forItem: "oauthToken"))
    }
    
    func repos(done: @escaping ([GithubRepo]?, Error?)->()) {
        
        let _ = client?.request("https://api.github.com/user/repos",
                                method: .GET,
                                success: { (response) in
            let repos = JSON(data: response.data).map { GithubRepo(json: $1) }
            
            done(repos, nil)
        }) { (error) in
            print(error)
            done(nil, error)
        }
    }
}
