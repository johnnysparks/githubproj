//
//  AppState.swift
//  githubproj
//
//  Created by John Sparks on 1/24/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift

extension Store {
    func fire(_ action: Action) {
        DispatchQueue.main.async {
            self.dispatch(action)
        }
    }
}

struct AppState: StateType {
    let github: GithubState
    let navigation: NavigationState
}

struct AppReducer: Reducer {
    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            github: githubReducer(action: action, state: state?.github),
            navigation: navigationReducer(action: action, state: state?.navigation)
        )
    }
}


