//
//  Cells.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import UIKit

// MARK - Base CollectionViewCell
class CollectionViewCell: UICollectionViewCell {
    static var reuseId: String { return "\(self)" }
}

// MARK - EmptyRepoCell
class EmptyRepoCell: CollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK - LoadingCell
class LoadingCell: CollectionViewCell {
    
    let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(activity)
        activity.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        activity.center = contentView.center
    }
}

// MARK - RepoCell
class RepoCell: CollectionViewCell {
    
    let label = UILabel()
    let loadingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = UIColor.white
        loadingLabel.textColor = UIColor.lightText
        contentView.addSubview(label)
        contentView.addSubview(loadingLabel)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.5)
        loadingLabel.frame = CGRect(x: 0, y: bounds.height * 0.5, width: bounds.width, height: bounds.height * 0.5)
    }
}

class ProjectCell: CollectionViewCell {
    
    let label = UILabel()
    var project: GithubProject? {
        didSet {
            label.text = project?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textColor = UIColor.white
        contentView.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.5)
    }
}

class ProjectColumnCell: CollectionViewCell {
    
    let label = UILabel()
    var column: GithubProjectColumn? {
        didSet {
            label.text = column?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.brown
        label.textColor = UIColor.white
        contentView.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.5)
    }
}

class ProjectCardCell: CollectionViewCell {
    
    let label = UILabel()
    var card: GithubProjectCard? {
        didSet {
            guard let card = card else {
                label.text = "..."
                return
            }
            if let issue = store.state.github.cardIssues[card] {
                label.text = issue.title
            }
            else if store.state.github.cardRequests.contains(card) {
                label.text = "Loading..."
            } else {
                label.text = card.note
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.purple
        label.textColor = UIColor.white
        contentView.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        label.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.5)
    }
}
