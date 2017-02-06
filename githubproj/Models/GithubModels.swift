//
//  GithubModels.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK - GithubIssue
struct GithubIssue {
    let id: String
    let number: UInt
    let state: String
    let title: String
    let body: String?
    
    init(json: JSON) {
        id = json["id"].stringValue
        number = json["number"].uIntValue
        state = json["state"].stringValue
        title = json["title"].stringValue
        body = json["body"].string
    }
}

extension GithubIssue: Equatable { }

func ==(lhs: GithubIssue, rhs: GithubIssue) -> Bool {
    return lhs.id == rhs.id
}

extension GithubIssue: Hashable {
    var hashValue: Int { return id.hash }
}


// MARK - GithubProjectCard
struct GithubProjectCard {
    let id: String
    let note: String
    let issueUrl: String?
    
    init(json: JSON) {
        id = json["id"].stringValue
        note = json["note"].stringValue
        issueUrl = json["content_url"].string
    }
}

extension GithubProjectCard: Equatable { }

func ==(lhs: GithubProjectCard, rhs: GithubProjectCard) -> Bool {
    return lhs.id == rhs.id
}

extension GithubProjectCard: Hashable {
    var hashValue: Int { return id.hash }
}


// MARK - GithubProjectColumn
struct GithubProjectColumn {
    let id: String
    let name: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
}

extension GithubProjectColumn: Equatable { }

func ==(lhs: GithubProjectColumn, rhs: GithubProjectColumn) -> Bool {
    return lhs.id == rhs.id
}

extension GithubProjectColumn: Hashable {
    var hashValue: Int { return id.hash }
}


// MARK - GithubProject
struct GithubProject {
    let id: String
    let name: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
}

extension GithubProject: Equatable { }

func ==(lhs: GithubProject, rhs: GithubProject) -> Bool {
    return lhs.id == rhs.id
}

extension GithubProject: Hashable {
    var hashValue: Int { return id.hash }
}


// MARK - GithubUser
struct GithubUser {
    let name: String?
    let id: String
    let url: String?
    let reposUrl: String?
    
    init?(json: JSON?) {
        guard let json = json else { return nil }
        name = json["login"].string
        id = json["id"].stringValue
        url = json["url"].string
        reposUrl = json["repos_url"].string
    }
}

extension GithubUser: Equatable { }

func ==(lhs: GithubUser, rhs: GithubUser) -> Bool {
    return lhs.id == rhs.id
}

extension GithubUser: Hashable {
    var hashValue: Int { return id.hash }
}


// MARK - GithubRepo
struct GithubRepo {
    let name: String?
    let id: String
    let owner: GithubUser?
    
    var projectsURL: String? {
        guard let username = owner?.name, let repoName = name else { return nil }
        return "https://api.github.com/repos/\(username)/\(repoName)/projects"
    }
    
    init(json: JSON) {
        name = json["name"].string
        id = json["id"].stringValue
        owner = GithubUser(json: json["owner"])
    }
}

extension GithubRepo: Equatable { }

func ==(lhs: GithubRepo, rhs: GithubRepo) -> Bool {
    return lhs.id == rhs.id
}

extension GithubRepo: Hashable {
    var hashValue: Int { return id.hash }
}

