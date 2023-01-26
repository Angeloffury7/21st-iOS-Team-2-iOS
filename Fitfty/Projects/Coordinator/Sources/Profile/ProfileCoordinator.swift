//
//  ProfileCoordinator.swift
//  Coordinator
//
//  Created by 임영선 on 2022/12/13.
//  Copyright © 2022 Fitfty. All rights reserved.
//

import Foundation
import UIKit
import Profile
import Common

final class ProfileCoordinator: Coordinator {
    
    var type: CoordinatorType { .profile }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: BaseNavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationConrtoller: BaseNavigationController = BaseNavigationController()) {
        self.navigationController = navigationConrtoller
    }
    
    func start() {
        let viewController = makeProfileViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}

private extension ProfileCoordinator {
    func makeProfileViewController() -> UIViewController {
        let viewController = MyProfileViewController(coordinator: self)
        return viewController
    }
    
    func makeProfileBottomSheetViewController() -> UIViewController {
        let viewController = MyPostBottomSheetViewController(coordinator: self)
        let bottomSheetViewController = BottomSheetViewController(
            style: .custom(196),
            contentViewController: viewController
        )
        return bottomSheetViewController
    }
    
    func makeUploadCodyCoordinator() -> UploadCodyCoordinator {
        let coordinator = UploadCodyCoordinator()
        coordinator.parentCoordinator = self
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        return coordinator
    }
}

extension ProfileCoordinator: MyProfileCoordinatorInterface {
    
    func showPost() {
        let postViewController = MyPostViewController(coordinator: self)
        postViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(postViewController, animated: true)
    }
    
    func showBottomSheet() {
        let bottomSheetViewController = makeProfileBottomSheetViewController()
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        navigationController.present(bottomSheetViewController, animated: false)
    }
    
    func showUploadCody() {
        let coordinator = makeUploadCodyCoordinator()
        coordinator.start()
        coordinator.navigationController.modalPresentationStyle = .overFullScreen
        navigationController.present(coordinator.navigationController, animated: true)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: false)
    }
    
    func popToRoot() {
        navigationController.popToRootViewController(animated: true)
    }
    
}

extension ProfileCoordinator: CoordinatorFinishDelegate {
    
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childDidFinish(childCoordinator, parent: self)
    }
}
