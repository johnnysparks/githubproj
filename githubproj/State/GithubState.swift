//
//  GithubState.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift

enum LoadingState {
    case refreshing
    case loading
    case ready
    case done
}

enum SortDirection {
    case asc, desc, natural
}


struct RepoListState: StateType {
    var loading: LoadingState = .ready
    var projectLists: [String: ProjectListState] = [:]
    var sort: SortDirection = .natural
    var repos: [GithubRepo] = []
    var items: [ListItem] {
        var o: [ListItem] = []
        
        if loading == .refreshing {
            o.append(LoadingListItem())
        }
        let sortedRepos = sort == .natural ? repos : repos.sorted() {
            guard let a = $0.name, let b = $1.name else { return false }
            return sort == .asc ? a < b : a > b;
        }
        sortedRepos.forEach { (repo) in
            // Only include projects that are loading/ready or done w/ > 0
            var keep = true
            var message = "Waiting..."
            if let projectList = projectLists[repo.id] {
                if projectList.loading == .loading {
                    message = "Loading..."
                } else if projectList.loading == .done {
                    if projectList.projects.count == 0 {
                        keep = false
                    } else {
                        message = "\(projectList.projects.count) projects"
                    }
                }
            }
            if keep {
                o.append(RepoListItem(repo: repo, message: message))
            }
        }
        
        if [.ready, .loading].contains(loading) {
            o.append(LoadingListItem())
        }
        
        return o
    }
}


struct ProjectListState: StateType {
    let repo: GithubRepo
    var loading: LoadingState = .ready
    var columnLists: [String: ProjectColumnsListState] = [:]
    var projects: [GithubProject] = []
    var items: [ListItem] {
        var o: [ListItem] = []
        if loading == .refreshing {
            o.append(LoadingListItem())
        }
        o += projects.map { ProjectListItem(repo: repo, project: $0) } as [ListItem]
        if [.ready, .loading].contains(loading) {
            o.append(LoadingListItem())
        }
        return o
    }
    
    init(repo: GithubRepo) {
        self.repo = repo
    }
}

struct ProjectColumnsListState: StateType {
    let repo: GithubRepo
    let project: GithubProject
    var loading: LoadingState = .ready
    var cardLists: [String: ProjectCardsListState] = [:]
    var columns: [GithubProjectColumn] = []
    var items: [ListItem] {
        var o: [ListItem] = []
        if loading == .refreshing {
            o.append(LoadingListItem())
        }
        o += columns.map { ProjectColumnListItem(repo: repo, project: project, column: $0) } as [ListItem]
        if [.ready, .loading].contains(loading) {
            o.append(LoadingListItem())
        }
        return o
    }
    init(repo: GithubRepo, project: GithubProject) {
        self.repo = repo
        self.project = project
    }
}

struct ProjectCardsListState: StateType {
    let repo: GithubRepo
    let project: GithubProject
    let column: GithubProjectColumn
    var loading: LoadingState = .ready
    var cards: [GithubProjectCard] = []
    var items: [ListItem] {
        var o: [ListItem] = []
        if loading == .refreshing {
            o.append(LoadingListItem())
        }
        o += cards.map { ProjectCardListItem(repo: repo, project: project, column: column, card: $0) } as [ListItem]
        if [.ready, .loading].contains(loading) {
            o.append(LoadingListItem())
        }
        return o
    }
    init(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn) {
        self.repo = repo
        self.project = project
        self.column = column
    }
}

enum ProjectColumnViewState {
    case normal
    case reorder
}

// MARK - State
struct GithubState: StateType {
    
    // Root Model
    var repoList = RepoListState()
    var cardIssues: [GithubProjectCard: GithubIssue] = [:]
    var cardColumns: [GithubProjectCard: String] = [:]
    
    // Request queues
    var projectRequests: Set<GithubRepo> = Set()
    var columnCardRequests: Set<GithubProjectColumn> = Set()
    var cardRequests: Set<GithubProjectCard> = Set()
    
    // Layout
    var projectColumnState: ProjectColumnViewState = .normal
    
    // Helper Methods
    func shouldLoadProjectsFor(repo: GithubRepo) -> Bool {
        let queueEmpty = projectRequests.count < 2
        let readyToLoad = (repoList.projectLists[repo.id]?.loading ?? .loading) == .ready
        return queueEmpty && readyToLoad
    }
    
    func shouldLoadRepos() -> Bool {
        return repoList.loading == .ready
    }
    
    func shouldLoad(cardsFor column: GithubProjectColumn, project: GithubProject, repo: GithubRepo) -> Bool {
        let queueEmpty = columnCardRequests.count < 2
        let readyToLoad = (repoList.projectLists[repo.id]?.columnLists[project.id]?.cardLists[column.id]?.loading ?? .loading) == .ready
        return queueEmpty && readyToLoad
    }
    
    func shouldLoad(card: GithubProjectCard) -> Bool {
        let queueEmpty = cardRequests.count < 2
        let readyToLoad = !cardRequests.contains(card)
        let hasIssue = card.issueUrl != nil
        let loaded = cardIssues[card] != nil
        return queueEmpty && readyToLoad && hasIssue && !loaded
    }
    
    func projectsListFor(repo: GithubRepo) -> [ListItem] {
        return repoList.projectLists[repo.id]!.items
    }
    
    func columnsListFor(repo: GithubRepo, project: GithubProject) -> [ListItem] {
        return repoList.projectLists[repo.id]?.columnLists[project.id]?.items ?? []
    }
    
    func columnCardListFor(repo: GithubRepo, project: GithubProject) -> [ListItem] {
        var items: [ListItem] = []
        let columnList = repoList.projectLists[repo.id]?.columnLists[project.id]
        columnList?.cardLists.forEach { (columnId, cardList) in
            items.append(ProjectColumnListItem(repo: repo, project: project, column: cardList.column))
            items.append(contentsOf: cardList.items)
        }
        return items
    }
    
    func cardListFor(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn) -> [ListItem] {
        return repoList.projectLists[repo.id]?.columnLists[project.id]?.cardLists[column.id]?.items ?? []
    }
}


// MARK - Reducer
func githubReducer(action: Action, state: GithubState?) -> GithubState {
    var state = state ?? GithubState()
    
    switch action {
    case _ as RefreshReposAction:
        state.repoList.loading = .refreshing
        
    case _ as LoadReposAction:
        state.repoList.loading = .loading
        
    case let action as ReposLoadedAction:
        state.repoList.loading = .done
        state.repoList.repos = action.repos
        action.repos.forEach {
            state.repoList.projectLists[$0.id] = ProjectListState(repo: $0)
        }
        
    case let action as ReposSortAction:
        state.repoList.sort = action.direction
        
    case let action as LoadProjectsAction:
        var list = state.repoList.projectLists[action.repo.id] ?? ProjectListState(repo: action.repo)
        list.loading = .loading
        state.repoList.projectLists[action.repo.id] = list
        state.projectRequests.insert(action.repo)
        
    case let action as ProjectsLoadedAction:
        var list = state.repoList.projectLists[action.repo.id] ?? ProjectListState(repo: action.repo)
        list.projects = action.projects
        list.loading = .done
        state.repoList.projectLists[action.repo.id] = list
        state.projectRequests.remove(action.repo)
    
    case let action as LoadProjectColumnsAction:
        var list = state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id] ?? ProjectColumnsListState(repo: action.repo, project: action.project)
        list.loading = .loading
        state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id] = list
        
    case let action as ProjectColumnsLoadedAction:
        var list = state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id] ?? ProjectColumnsListState(repo: action.repo, project: action.project)
        list.columns = action.columns
        action.columns.forEach {
            list.cardLists[$0.id] = ProjectCardsListState(repo: action.repo, project: action.project, column: $0)
        }
        list.loading = .done
        state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id] = list
    
    case let action as LoadCardsAction:
        var list = state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id]?.cardLists[action.column.id] ?? ProjectCardsListState(repo: action.repo, project: action.project, column: action.column)
        list.loading = .loading
        state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id]?.cardLists[action.column.id] = list
        
    case let action as CardsLoadedAction:
        var list = state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id]?.cardLists[action.column.id] ?? ProjectCardsListState(repo: action.repo, project: action.project, column: action.column)
        list.cards = action.cards
        list.loading = .done
        list.cards.forEach {
            state.cardColumns[$0] = action.column.id
        }
        state.repoList.projectLists[action.repo.id]?.columnLists[action.project.id]?.cardLists[action.column.id] = list

    case let action as LoadCardIssueAction:
        state.cardRequests.insert(action.card)

    case let action as CardIssueLoadedAction:
        state.cardRequests.remove(action.card)
        state.cardIssues[action.card] = action.issue
        
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

// MARK - Project / Columns
struct LoadProjectColumnsAction: Action {
    let repo: GithubRepo
    let project: GithubProject
    init(repo: GithubRepo, project: GithubProject) {
        self.repo = repo
        self.project = project
        GithubAPI.shared.columns(project: project) { (columns, error) in
            if let columns = columns {
                store.dispatch(ProjectColumnsLoadedAction(repo: repo, project: project, columns: columns))
            }
        }
    }
}

struct ProjectColumnsLoadedAction: Action {
    let repo: GithubRepo
    let project: GithubProject
    let columns: [GithubProjectColumn]
}


// MARK - Project / Column / Cards
struct LoadCardsAction: Action {
    let repo: GithubRepo
    let project: GithubProject
    let column: GithubProjectColumn
    init(repo: GithubRepo, project: GithubProject, column: GithubProjectColumn) {
        self.repo = repo
        self.project = project
        self.column = column
        GithubAPI.shared.cards(column: column) { (cards, error) in
            if let cards = cards {
                store.dispatch(CardsLoadedAction(repo: repo, project: project, column: column, cards: cards))
            }
        }
    }
}

struct CardsLoadedAction: Action {
    let repo: GithubRepo
    let project: GithubProject
    let column: GithubProjectColumn
    let cards: [GithubProjectCard]
}

// MARK -- Project / Column / Card / Issues
struct LoadCardIssueAction: Action {
    let card: GithubProjectCard
    
    init(card: GithubProjectCard) {
        self.card = card
        GithubAPI.shared.issue(forCard: card) { (issue, error) in
            if let issue = issue {
                store.dispatch(CardIssueLoadedAction(card: card, issue: issue))
            }
        }
    }
}

struct CardIssueLoadedAction: Action {
    let card: GithubProjectCard
    let issue: GithubIssue
}
