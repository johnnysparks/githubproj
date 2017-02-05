//
//  GithubModels.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GithubProjectColumn: Equatable {
    let id: String
    let name: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
}

func ==(lhs: GithubProjectColumn, rhs: GithubProjectColumn) -> Bool {
    return lhs.id == rhs.id
}

// MARK - GithubProject
struct GithubProject: Equatable {
    let id: String
    let name: String
    
    init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
    }
}

func ==(lhs: GithubProject, rhs: GithubProject) -> Bool {
    return lhs.id == rhs.id
}


// MARK - GithubUser
struct GithubUser: Equatable {
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

func ==(lhs: GithubUser, rhs: GithubUser) -> Bool {
    return lhs.id == rhs.id
}


// MARK - GithubRepo
struct GithubRepo: Equatable {
    let name: String?
    let id: String
    let owner: GithubUser?
    
    var projectsURL: String? {
        guard let username = owner?.name, let repoName = name else { return nil }
        return "https://api.github.com/repos/\(username)/\(repoName)/projects"
    }
    
    var message: String {
        if store.state.github.loadingRepoProjects.contains(self) {
            return "Loading ..."
        } else if let projects = store.state.github.repoProjects[id] {
            return "\(projects.count) projects"
        }
        return "Waiting..."
    }
    
    init(json: JSON) {
        name = json["name"].string
        id = json["id"].stringValue
        owner = GithubUser(json: json["owner"])
    }
}

func ==(lhs: GithubRepo, rhs: GithubRepo) -> Bool {
    return lhs.id == rhs.id
}

