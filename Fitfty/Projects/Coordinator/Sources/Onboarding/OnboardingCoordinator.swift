//
//  OnboardingCoordinator.swift
//  Coordinator
//
//  Created by Watcha-Ethan on 2023/02/11.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import UIKit

import Onboarding
import Common
import Core

final class OnboardingCoordinator: Coordinator {
    var type: CoordinatorType { .onboarding }
    var finishDelegate: CoordinatorFinishDelegate?
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: BaseNavigationController
    
    init(navigationController: BaseNavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = makeNicknameViewController()
        navigationController.pushViewController(viewController, animated: true)
        
        let viewController2 = makeGenderViewController()
        navigationController.pushViewController(viewController2, animated: true)
    }
}

extension OnboardingCoordinator: OnboardingCoordinatorInterface {
    func pushGenderView() {
        let viewController = makeGenderViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushStyleView() {
        
    }
    
    func pushMainFeedView() {
        
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
}

private extension OnboardingCoordinator {
    func makeNicknameViewController() -> UIViewController {
        let viewController = NicknameViewController(
            viewModel: NicknameViewModel(
                repository: DefaultOnboardingRepository()),
            coordinator: self
        )
        return viewController
    }
    
    func makeGenderViewController() -> UIViewController {
        let viewController = GenderViewController(
            coordinator: self
        )
        return viewController
    }
    
    func makeStyleViewController() {
        
    }
}
