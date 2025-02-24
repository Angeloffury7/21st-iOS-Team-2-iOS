//
//  ProfileViewController.swift
//  Profile
//
//  Created by 임영선 on 2022/12/04.
//  Copyright © 2022 Fitfty. All rights reserved.
//

import UIKit
import Common
import Combine
import Core

final public class ProfileViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private var viewModel: ProfileViewModel
    private var coordinator: ProfileCoordinatorInterface
    private var profileType: ProfileType
    private var presentType: ProfilePresentType
    private var nickname: String?
    private var isRefreshProfileImage = false
    private var dataSource: UICollectionViewDiffableDataSource<ProfileSectionKind, ProfileCellModel>?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: postLayout())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(FeedImageCell.self,
                                forCellWithReuseIdentifier: FeedImageCell.className)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = CommonAsset.Colors.gray01.color
        return view
    }()
    
    private lazy var loadingIndicatorView: LoadingView = {
        let loadingView: LoadingView = .init(backgroundColor: .white.withAlphaComponent(0), alpha: 1)
        loadingView.stopAnimating()
        return loadingView
    }()
    
    private lazy var emptyView: EmptyView = {
        let view = EmptyView()
        view.isHidden = true
        view.setButtonAction(self, action: #selector(didTapEmptyViewButton))
        return view
    }()
    
    private let miniProfileView = MiniProfileView(imageSize: 48, frame: .zero)
    
    private var profileFilePath: String?
    private var myMessage: String?
    private var menuType: MenuType = .myFitfty
    
    private var headerViewElementKind: String {
        switch profileType {
        case .userProfile:
            return UserProfileHeaderView.className
        case .myProfile:
            return MyProfileHeaderView.className
        }
    }
    
    public init(
        coordinator: ProfileCoordinatorInterface,
        profileType: ProfileType,
        presentType: ProfilePresentType,
        viewModel: ProfileViewModel,
        nickname: String?
    ) {
        self.coordinator = coordinator
        self.profileType = profileType
        self.presentType = presentType
        self.viewModel = viewModel
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        coordinator.finishedTapGesture()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        bind()
        setUserProfile()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        setMyProfile()
        emptyView.isHidden = true
    }
    
    private func setUp() {
        setUpConstraintLayout()
        setUpDataSource()
        registerHeaderView()
        setMiniProfileView(isHidden: true)
    }
    
    @objc func didTapMoreVerticalButton(_ sender: Any?) {
        viewModel.input.didTapMoreVertical()
    }
    
    @objc func didTapSettingButton(_ sender: UIButton) {
        coordinator.showSetting()
    }
    
    @objc func didTapBackButton(_ sender: UITapGestureRecognizer) {
        coordinator.finished()
    }
    
    @objc func didTapMyFitftyMenu(_ sender: Any?) {
        guard menuType == .bookmark else {
            return
        }
        isRefreshProfileImage = false
        collectionView.isScrollEnabled = true
        emptyView.isHidden = true
        menuType = .myFitfty
        viewModel.input.didTapMenu(.myFitfty)
    }
    
    @objc func didTapBookmarkMenu(_ sender: Any?) {
        guard menuType == .myFitfty else {
            return
        }
        isRefreshProfileImage = false
        collectionView.isScrollEnabled = true
        emptyView.isHidden = true
        menuType = .bookmark
        viewModel.input.didTapMenu(.bookmark)
    }
    
    @objc func didTapEmptyViewButton(_ sender: Any?) {
        switch menuType {
        case .myFitfty:
            coordinator.showMyFitfty(.uploadMyFitfty)
        case .bookmark:
            coordinator.switchMainTab()
        }
    }
}

private extension ProfileViewController {
    
    func bind() {
        viewModel.state.compactMap { $0 }
            .sinkOnMainThread(receiveValue: { [weak self] state in
                switch state {
                case .update(let response):
                    self?.update(response)
                case .errorMessage(let message):
                    self?.showAlert(message: message)
                case .isLoading(let isLoading):
                    isLoading ? self?.loadingIndicatorView.startAnimating() : self?.loadingIndicatorView.stopAnimating()
                case .sections(let sections):
                    self?.applySnapshot(sections)
                case .showPost(let profileType, let boardToken):
                    self?.coordinator.showPost(profileType: profileType, boardToken: boardToken)
                case .report(let repotedToken):
                    self?.coordinator.showReport(reportedToken: repotedToken)
                }
            }).store(in: &cancellables)
    }
    
    func setUpConstraintLayout() {
        view.addSubviews(collectionView, miniProfileView, seperatorView, loadingIndicatorView, emptyView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            miniProfileView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniProfileView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniProfileView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            miniProfileView.heightAnchor.constraint(equalToConstant: 66),
            
            seperatorView.heightAnchor.constraint(equalToConstant: 1),
            seperatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seperatorView.bottomAnchor.constraint(equalTo: miniProfileView.bottomAnchor),
            
            loadingIndicatorView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            loadingIndicatorView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            loadingIndicatorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.topAnchor.constraint(equalTo: view.topAnchor, constant: profileType.headerHeight+160),
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 86),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -86),
            emptyView.heightAnchor.constraint(equalToConstant: 92)
        ])
    }
    
    func setUserProfile() {
        switch profileType {
        case .myProfile:
            break
        case .userProfile:
            guard let nickname = nickname else {
                return
            }
            viewModel.input.viewDidLoadWithoutMenu(nickname: nickname)
        }
    }
    
    func setMyProfile() {
        switch profileType {
        case .userProfile:
            break
        case .myProfile:
            isRefreshProfileImage = true
            viewModel.input.viewWillAppearWithMenu(menuType: menuType)
        }
    }
    
    func setNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
       
        switch profileType {
        case .userProfile:
            navigationController?.navigationBar.isHidden = false
            navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                image: CommonAsset.Images.btnMoreVertical.image,
                style: .plain,
                target: self,
                action: #selector(didTapMoreVerticalButton)
            )
            navigationItem.rightBarButtonItem?.tintColor = .black
        case .myProfile:
            navigationController?.navigationBar.isHidden = true
        }
        
        let cancelButton = UIBarButtonItem(
                image: CommonAsset.Images.btnArrowleft.image,
                style: .plain,
                target: self,
                action: #selector(didTapBackButton(_:))
            )
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func registerHeaderView() {
        switch profileType {
        case .userProfile:
            collectionView.register(UserProfileHeaderView.self,
                                    forSupplementaryViewOfKind: headerViewElementKind)
        case .myProfile:
            collectionView.register(MyProfileHeaderView.self,
                                    forSupplementaryViewOfKind: headerViewElementKind)
        }
    }
    
    func setMiniProfileView(isHidden: Bool) {
        miniProfileView.isHidden = isHidden
        seperatorView.isHidden = isHidden
    }
    
    private func update(_ response: ProfileResponse) {
        guard let data = response.data else {
            return
        }
        self.profileFilePath = data.profilePictureUrl
        self.myMessage = data.message ?? "\(data.nickname)의 프로필이에요."
        self.nickname = data.nickname
        
        miniProfileView.setUp(
            filepath: data.profilePictureUrl,
            nickname: data.nickname
        )
    }

}

private extension ProfileViewController {
    
    func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ProfileSectionKind, ProfileCellModel>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
                switch item {
                case .feed(let filepath, _, _):
                    guard let cell = collectionView.dequeueReusableCell(FeedImageCell.self, for: indexPath) else {
                        return UICollectionViewCell()
                    }
                    cell.setUp(filepath: filepath)
                    return cell
                }
            })
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            switch self?.profileType {
            case .userProfile:
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: UserProfileHeaderView.className,
                    for: indexPath) as? UserProfileHeaderView else {
                    return UICollectionReusableView()
                }
                if let nickname = self?.nickname,
                   let content = self?.myMessage {
                    supplementaryView.profileView.setUp(
                        nickname: nickname,
                        content: content,
                        filepath: self?.profileFilePath,
                        refresh: self?.isRefreshProfileImage ?? true
                    )
                }
                return supplementaryView
                
            case .myProfile:
                guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: MyProfileHeaderView.className,
                    for: indexPath) as? MyProfileHeaderView else {
                    return UICollectionReusableView()
                }
                if let nickname = self?.nickname,
                   let content = self?.myMessage {
                    supplementaryView.profileView.setUp(
                        nickname: nickname,
                        content: content,
                        filepath: self?.profileFilePath,
                        refresh: self?.isRefreshProfileImage ?? true
                    )
                }
                supplementaryView.menuView.setMyFitftyButtonTarget(self, action: #selector(self?.didTapMyFitftyMenu))
                supplementaryView.menuView.setBookmarkButtonTarget(self, action: #selector(self?.didTapBookmarkMenu))
                supplementaryView.menuView.setMenuState(self?.menuType ?? .myFitfty)
                supplementaryView.setButtonTarget(target: self, action: #selector(self?.didTapSettingButton(_:)))
                
                switch self?.presentType {
                case .mainProfile:
                    supplementaryView.setBackButton(self, action: #selector(self?.didTapBackButton(_:)))
                case .tabProfile, .none:
                    break
                }
                
                return supplementaryView
                
            default:
                return UICollectionReusableView()
            }
        }
    }
    
    func applySnapshot(_ sections: [ProfileSection]) {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSectionKind, ProfileCellModel>()
        sections.forEach {
            snapshot.appendSections([$0.sectionKind])
            snapshot.appendItems($0.items)
        }
        snapshot.reloadSections([.feed])
        dataSource?.apply(snapshot, animatingDifferences: false) {
            guard sections.first?.items.count == 0 else {
                return
            }
            self.collectionView.isScrollEnabled = false
            self.emptyView.isHidden = false
            self.emptyView.setUp(self.menuType)
        }
    }
    
    func postLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/2),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(1/2)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 27, leading: 12, bottom: 5, trailing: 12)
        
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .absolute(UIScreen.main.bounds.width),
                    heightDimension: .estimated(profileType.headerHeight)
                ),
                elementKind: headerViewElementKind,
                alignment: .top
            )
        ]
       
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

extension ProfileViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch profileType {
        case .userProfile:
            viewModel.input.didTapPostWithoutMenu(selectedIndex: indexPath.row)
        case .myProfile:
            viewModel.input.didTapPostWithMenu(selectedIndex: indexPath.row, menuType: menuType)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= profileType.headerHeight {
            setMiniProfileView(isHidden: false)
        } else {
            setMiniProfileView(isHidden: true)
        }
    }
    
}
