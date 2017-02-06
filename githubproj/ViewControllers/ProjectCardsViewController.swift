//
//  ProjectCardsViewController.swift
//  githubproj
//
//  Created by John Sparks on 2/5/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation


class ProjectCardsViewController: BaseViewController {
    
    let listView = ListView()
    
    var repo: GithubRepo?
    var project: GithubProject?
    var column: GithubProjectColumn?
    
    func set(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn) {
        self.repo = repo
        self.project = project
        self.column = column
        store.dispatch(LoadCardsAction(repo: repo, project: project, column: column))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
    }
    
    override func newState(state: AppState) {
        if let repo = repo, let project = project, let column = column {
            listView.items = state.github.cardListFor(repo: repo, project: project, column: column)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
}
