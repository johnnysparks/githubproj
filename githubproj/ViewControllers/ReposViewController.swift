//
//  ViewController.swift
//  githubproj
//
//  Created by John Sparks on 1/24/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import UIKit
import ReSwift

class ReposViewController: BaseViewController {
    
    let reposView = ReposView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(reposView)
        
        GithubAPI.shared.authorize { error in
            store.fire(RefreshReposAction())
        }
    }
    
    override func newState(state: AppState) {
        reposView.state = state.github
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        reposView.frame = view.bounds
    }
}


class ReposView: UIView {
    
    let sortControlTopMargin: CGFloat = 20.0
    let sortControlHeight: CGFloat = 44.0
    let sortControl = UISegmentedControl(items: ["☝️", "👇"])
    let projectList = ListView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sortControl.tintColor = UIColor.yellow
        sortControl.addTarget(self, action: #selector(ReposView.changedSort), for: .valueChanged)
        
        addSubview(projectList)
        addSubview(sortControl)
        
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK -- Segmented Control
    func changedSort(){
        store.dispatch(ReposSortAction(direction: sortControl.selectedSegmentIndex == 0 ? .desc : .asc))
    }
    
    var state: GithubState = GithubState() {
        didSet {
            projectList.items = state.repoFeed
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sortControl.frame = CGRect(x: 0, y: sortControlTopMargin, width: bounds.width, height: sortControlHeight)
        projectList.frame = CGRect(x: 0, y: sortControl.frame.maxY, width: bounds.width, height: bounds.height - sortControl.frame.maxY)
    }
}

