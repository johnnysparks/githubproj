//
//  ListItems.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift

// MARK - Feed Item Helper Models
protocol ListItem {
    var touchHandler: (() -> ())? { get }
    var displayHandler: (() -> ())? { get }
}

struct EmptyListItem: ListItem {
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
}

struct LoadingListItem: ListItem {
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
}

struct RepoListItem: ListItem {
    let repo: GithubRepo
    let message: String
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(repo: GithubRepo, message: String){
        self.repo = repo
        self.message = message
        
        displayHandler = {
            if store.state.github.shouldLoadProjectsFor(repo: repo) {
                store.fire(LoadProjectsAction(repo: repo))
            }
        }
        
        touchHandler = {
            let vc = ProjectsListViewController()
            vc.repo = repo
            store.fire(PushNavigationAction(vc: vc))
        }
    }
}

struct ProjectListItem: ListItem {
    let project: GithubProject
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(project: GithubProject) {
        self.project = project
        
        touchHandler = {
            let vc = ProjectViewController()
            vc.project = project
            store.fire(PushNavigationAction(vc: vc))
        }
    }
}

struct ProjectColumnListItem: ListItem {
    let column: GithubProjectColumn
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(column: GithubProjectColumn) {
        self.column = column
    }
}
