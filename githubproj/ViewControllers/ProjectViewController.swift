//
//  ProjectViewController.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation

class ProjectViewController: BaseViewController {
    
    let listView = ListView()
    
    var repo: GithubRepo?
    var project: GithubProject?
        
    func set(repo: GithubRepo, project: GithubProject) {
        self.repo = repo
        self.project = project
        store.dispatch(LoadProjectColumnsAction(repo: repo, project: project))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
    }
    
    override func newState(state: AppState) {
        if let repo = repo, let project = project {
            listView.items = state.github.columnsListFor(repo: repo, project: project)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
}
