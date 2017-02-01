//
//  AppState.swift
//  githubproj
//
//  Created by John Sparks on 1/24/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift
import SwiftyJSON

protocol FeedItem { }

struct EmptyFeedItem: FeedItem { }
struct LoadingFeedItem: FeedItem { }

struct GithubRepo: Equatable, FeedItem {
    let name: String?
    let id: String
    
    init(json: JSON){
        name = json["name"].string
        id = json["id"].stringValue
    }
}

func ==(lhs: GithubRepo, rhs: GithubRepo) -> Bool {
    return lhs.id == rhs.id
}

enum SortDirection {
    case asc, desc
}

struct ReposSortAction: Action {
    let direction: SortDirection
}

struct RefreshReposAction: Action {
    init() {
        GithubAPI.shared.repos() { repos, error in
            if let repos = repos {
                store.dispatch(ReposLoadedAction(repos: repos))
            }
        }
    }
}
struct LoadReposAction: Action {
    init() {
        GithubAPI.shared.repos() { repos, error in
            if let repos = repos {
                store.dispatch(ReposLoadedAction(repos: repos))
            }
        }
    }
}

struct ReposLoadedAction: Action {
    let repos: [GithubRepo]
}

struct AppState: StateType {
    var loadingRepos = false
    var repoSortDirection: SortDirection?
    var repos: [GithubRepo] = []
    var repoFeed: [FeedItem] = [EmptyFeedItem()]
}

struct AppReducer: Reducer {
    
    func sorted(repos:[GithubRepo], by: SortDirection?) -> [GithubRepo] {
        guard let by = by else { return repos }
        return repos.sorted {
            guard let a = $0.name, let b = $1.name else {
                return false
            }
            return by == .asc ? a < b : a > b;
        }
    }
    
    
    func handleAction(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()
        
        switch action {
        case _ as RefreshReposAction:
            
            state.loadingRepos = true
            state.repos = []
            state.repoFeed.insert(LoadingFeedItem(), at: 0)
            
        case _ as LoadReposAction:
            state.loadingRepos = true
            state.repos = sorted(repos: state.repos, by: state.repoSortDirection)
            state.repoFeed = state.repos
            state.repoFeed.append(LoadingFeedItem())
            
        case let action as ReposLoadedAction:
            state.loadingRepos = false
            state.repos = action.repos
            state.repos = sorted(repos: state.repos, by: state.repoSortDirection)
            state.repoFeed = state.repos
            
        case let action as ReposSortAction:
            state.repoSortDirection = action.direction
            state.repos = sorted(repos: state.repos, by: state.repoSortDirection)
            state.repoFeed = state.repos
            
        default: break
        }
        return state
    }
}


