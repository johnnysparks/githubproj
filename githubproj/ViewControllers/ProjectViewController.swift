//
//  ProjectViewController.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ProjectViewController: BaseViewController {
    
    let listView = ListView()
    
    var repo: GithubRepo?
    var project: GithubProject?
        
    func set(repo: GithubRepo, project: GithubProject) {
        self.repo = repo
        self.project = project
        store.fire(LoadProjectColumnsAction(repo: repo, project: project))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listView.backgroundColor = UIColor.green

//        GithubAPI.shared.authorize { (error) in
//            let repo = GithubRepo(json: JSON(["id":"80657829",
//                                              "name":"githubproj",
//                                              "owner" : [
//                                                "login": "johnnysparks",
//                                                "id":"5806820",
//                                                "url" : "https://api.github.com/users/johnnysparks"]]))
//            let project = GithubProject(json: JSON(["id":"358504", "name":"GithubProject Project"]))
//            
//            store.dispatch(ProjectsLoadedAction(repo: repo, projects: [project]))
//            store.fire(LoadProjectColumnsAction(repo: repo, project: project))
//            
//            self.set(repo: repo, project: project)
//        }
        
        view.addSubview(listView)
    }
    
    override func newState(state: AppState) {
        if let repo = repo, let project = project {
            listView.items = state.github.columnCardListFor(repo: repo, project: project)
            view.setNeedsLayout()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        listView.frame = view.bounds
        listView.layer.borderWidth = 1
        listView.layer.borderColor = UIColor.green.cgColor
    }
}
