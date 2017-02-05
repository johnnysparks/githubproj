//
//  NavigationState.swift
//  githubproj
//
//  Created by John Sparks on 2/4/17.
//  Copyright © 2017 beergramming. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

// The mainRouter is the "side effect" engine for the navigation reducer.
// The navigation state should be restorable from an encodable format,
// and UIViewControllers are not.
let mainRouter = Router()

// Router holds references to the various view controllers in the navigation / tab stack.
class Router {
    let nav = UINavigationController(rootViewController: ReposViewController())
    
    init(){
        nav.isNavigationBarHidden = true
    }
}

struct PushNavigationAction: Action {
    let vc: UIViewController
}

struct PopNavigationAction: Action { }

struct NavigationState: StateType {
    var router: Router {
        return mainRouter
    }
}

func navigationReducer(action: Action, state: NavigationState?) -> NavigationState {
    let state = state ?? NavigationState()
    
    switch action {
    case let action as PushNavigationAction:
        state.router.nav.pushViewController(action.vc, animated: true)
    case _ as PopNavigationAction:
        state.router.nav.popViewController(animated: true)
    default: break
    }
    return state
}
