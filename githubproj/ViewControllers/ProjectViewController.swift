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
    var project: GithubProject? {
        didSet {
            if let project = project {
                store.dispatch(LoadProjectColumnsAction(project: project))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
    }
    
    override func newState(state: AppState) {
        if let project = project {
            listView.items = state.github.columnsListFor(project: project)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
}
