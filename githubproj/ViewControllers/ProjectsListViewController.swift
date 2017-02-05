//
//  ProjectsViewController.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import UIKit


class ProjectsListViewController: BaseViewController {
    
    let listView = ListView()
    var repo: GithubRepo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
    }
    
    override func newState(state: AppState) {
        if let repo = repo {
            listView.items = state.github.projectsListFor(repo: repo)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
}
