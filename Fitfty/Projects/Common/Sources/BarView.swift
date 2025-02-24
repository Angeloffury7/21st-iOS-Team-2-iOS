//
//  BarView.swift
//  MainFeed
//
//  Created by 임영선 on 2023/01/12.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import UIKit

public final class BarView: UIView {

    private lazy var backgroundStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 항목"
        label.font = FitftyFont.appleSDBold(size: 20).font
        return label
    }()
    
    private lazy var chevronButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = CommonAsset.Colors.gray08.color
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = CommonAsset.Colors.gray04.color
        button.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
        return button
    }()
    
    private var isChevronButtonHidden: Bool
    
    public init(title: String, isChevronButtonHidden: Bool) {
        self.isChevronButtonHidden = isChevronButtonHidden
        super.init(frame: .zero)
        self.titleLabel.text = title
        setConstraintsLayout()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraintsLayout() {
        addSubviews(backgroundStackView, cancelButton)
        if isChevronButtonHidden {
            backgroundStackView.addArrangedSubviews(titleLabel)
            NSLayoutConstraint.activate([
                backgroundStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                backgroundStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                cancelButton.widthAnchor.constraint(equalToConstant: 32),
                cancelButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        } else {
            backgroundStackView.addArrangedSubviews(titleLabel, chevronButton)
            NSLayoutConstraint.activate([
                backgroundStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                backgroundStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),
                cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                cancelButton.widthAnchor.constraint(equalToConstant: 32),
                cancelButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
    }
    
    public func setCancelButtonTarget(target: Any?, action: Selector) {
        cancelButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    public func setTitleViewTarget(target: Any?, action: Selector) {
        backgroundStackView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    public func setTitle(title: String) {
        titleLabel.text = title
    }

}
