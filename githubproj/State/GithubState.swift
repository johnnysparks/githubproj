//
//  GithubState.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift

enum SortDirection {
    case asc, desc
}

// MARK - State
struct GithubState: StateType {
    
    var loadingRepoProjects: [GithubRepo] = []
    var repoProjects: [String: [GithubProject]] = [:]
    var repoProjectFeeds: [String: [ProjectListItem]] = [:]
    var projectColumns: [String: [GithubProjectColumn]] = [:]
    
    var loadingRepos = false
    var repoSortDirection: SortDirection?
    var repos: [GithubRepo] = []
    var repoFeed: [ListItem] = [EmptyListItem()]
    
    // Helper Methods
    func shouldLoadProjectsFor(repo: GithubRepo) -> Bool {
        let queueEmpty = loadingRepoProjects.count < 2
        let notLoaded = repoProjects[repo.id] == nil
        let notLoading = !loadingRepoProjects.contains(repo)
        return queueEmpty && notLoaded && notLoading
    }
    
    func shouldLoadRepos() -> Bool {
        return repos.count == 0 && !loadingRepos
    }
    
    func projectsListFor(repo: GithubRepo) -> [ListItem] {
        return (repoProjects[repo.id] ?? []).map { ProjectListItem(project: $0) }
    }
    
    func columnsListFor(project: GithubProject) -> [ListItem] {
        return (projectColumns[project.id] ?? []).map { ProjectColumnListItem(column: $0) }
    }
}


// MARK - Reducer
func githubReducer(action: Action, state: GithubState?) -> GithubState {
    var state = state ?? GithubState()
    
    func repoFeedItems() -> [RepoListItem] {
        // Create the starting list
        var items: [RepoListItem] = []
        
        // Sort the repos
        let sortedRepos = state.repos.sorted {
            guard let a = $0.name, let b = $1.name else {
                return false
            }
            return state.repoSortDirection == .asc ? a < b : a > b;
        }
        
        // Add a repo item for each repo with loaded projects
        for repo in sortedRepos {
            if state.loadingRepoProjects.contains(repo) {
                items.append(RepoListItem(repo: repo, message: "Loading ..."))
            } else if let projects = state.repoProjects[repo.id] {
                if projects.count > 0 {
                    items.append(RepoListItem(repo: repo, message: "\(projects.count) projects"))
                }
            } else {
                items.append(RepoListItem(repo: repo, message: "Waiting..."))
            }
        }
        
        return items
    }
    
    switch action {
    case _ as RefreshReposAction:
        state.loadingRepos = true
        state.repos = []
        state.repoFeed.insert(LoadingListItem(), at: 0)
        
    case _ as LoadReposAction:
        state.loadingRepos = true
        state.repoFeed = repoFeedItems()
        state.repoFeed.append(LoadingListItem())
        
    case let action as ReposLoadedAction:
        state.loadingRepos = false
        state.repos = action.repos
        state.repoFeed = repoFeedItems()
        
    case let action as ReposSortAction:
        state.repoSortDirection = action.direction
        state.repoFeed = repoFeedItems()
        
    case let action as LoadProjectsAction:
        state.loadingRepoProjects.append(action.repo)
        state.repoFeed = repoFeedItems()
        
    case let action as ProjectsLoadedAction:
        if let idx = state.loadingRepoProjects.index(of: action.repo) {
            state.loadingRepoProjects.remove(at: idx)
        }
        state.repoProjects[action.repo.id] = action.projects
        state.repoFeed = repoFeedItems()
    
    case let action as ProjectColumnsLoadedAction:
        state.projectColumns[action.project.id] = action.columns
    
    default: break
    }
    return state
}



// MARK - Actions

// MARK - Repos
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

// MARK - Projects
struct LoadProjectsAction: Action {
    let repo: GithubRepo
    init(repo: GithubRepo){
        self.repo = repo
        GithubAPI.shared.projects(repo: repo) { (projects, error) in
            if let projects = projects {
                store.dispatch(ProjectsLoadedAction(repo: repo, projects: projects))
            }
        }
    }
}

struct ProjectsLoadedAction: Action {
    let repo: GithubRepo
    let projects: [GithubProject]
}

struct LoadProjectColumnsAction: Action {
    let project: GithubProject
    init(project: GithubProject) {
        self.project = project
        GithubAPI.shared.columns(project: project) { (columns, error) in
            if let columns = columns {
                store.dispatch(ProjectColumnsLoadedAction(project: project, columns: columns))
            }
        }
    }
}

struct ProjectColumnsLoadedAction: Action {
    let project: GithubProject
    let columns: [GithubProjectColumn]
}


