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
    
    let repo: GithubRepo
    let project: GithubProject
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(repo: GithubRepo, project: GithubProject) {
        self.repo = repo
        self.project = project
        
        touchHandler = {
            let vc = ProjectViewController()
            vc.set(repo: repo, project: project)
            store.fire(PushNavigationAction(vc: vc))
        }
    }
}

struct ProjectColumnListItem: ListItem {
    let repo: GithubRepo
    let project: GithubProject
    let column: GithubProjectColumn
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn) {
        self.repo = repo
        self.project = project
        self.column = column
        
        touchHandler = {
            let vc = ProjectCardsViewController()
            vc.set(repo: repo, project: project, column: column)
            store.fire(PushNavigationAction(vc: vc))
        }
    }
}

struct ProjectCardListItem: ListItem {
    let repo: GithubRepo
    let project: GithubProject
    let column: GithubProjectColumn
    let card: GithubProjectCard
    
    var touchHandler: (() -> ())?
    var displayHandler: (() -> ())?
    
    init(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn, card: GithubProjectCard) {
        self.repo = repo
        self.project = project
        self.column = column
        self.card = card
    }
    
}
