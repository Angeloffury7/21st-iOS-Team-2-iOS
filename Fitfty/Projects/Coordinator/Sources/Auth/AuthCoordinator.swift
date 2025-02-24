//
//  AuthCoordinator.swift
//  Coordinator
//
//  Created by Watcha-Ethan on 2022/12/03.
//  Copyright © 2022 Fitfty. All rights reserved.
//

import UIKit

import Auth
import Common

final class AuthCoordinator: Coordinator {
    var type: CoordinatorType { .login }
    var finishDelegate: CoordinatorFinishDelegate?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: BaseNavigationController
    
    private let needsIntroView: Bool
    
    init(navigationController: BaseNavigationController, needsIntroView: Bool) {
        self.navigationController = navigationController
        self.needsIntroView = needsIntroView
    }
    
    func start() {
        if needsIntroView {
            pushIntroView()
        } else {
            pushAuthView()
        }
    }
}

extension AuthCoordinator: AuthCoordinatorInterface {
    func pushAuthView() {
        let viewController = makeAuthViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func pushIntroView() {
        let viewController = makeIntroViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushPermissionView() {
        let viewController = makePermissionViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushOnboardingFlow() {
        let coordinator = makeOnboardingCoordinator()
        coordinator.start()
    }
    
    func pushMainFeedFlow() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

private extension AuthCoordinator {
    func makeAuthViewController() -> UIViewController {
        let viewController = AuthViewController(
            viewModel: AuthViewModel(),
            coordinator: self
        )
        return viewController
    }
    
    func makeIntroViewController() -> UIViewController {
        let viewController = AuthIntroViewController(
            coordinator: self
        )
        return viewController
    }
    
    func makePermissionViewController() -> UIViewController {
        let viewController = AuthPermissionViewController(
            coordinator: self
        )
        return viewController
    }
    
    func makeOnboardingCoordinator() -> Coordinator {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        coordinator.finishDelegate = finishDelegate
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        
        return coordinator
    }
}
