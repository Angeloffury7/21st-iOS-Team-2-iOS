//
//  DetailReportViewModel.swift
//  Profile
//
//  Created by 임영선 on 2023/02/14.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation
import Common
import Combine
import Core

protocol DetailReportViewModelInput {
    
    var input: DetailReportViewModelInput { get }
    func didTapTitle(index: Int)
    func viewDidLoad()
    func didTapReportButton()
}

public final class DetailReportViewModel {
    
    private var currentState: CurrentValueSubject<ViewModelState?, Never> = .init(nil)
    private var cancellables: Set<AnyCancellable> = .init()
    private var userManager: UserManager
    private var userToken: String?
    private var boardToken: String?
    private var reportType: ReportType
    private var fitftyRepository: FitftyRepository
    private var reports: [(detailReportType: DetailReportType, isSelected: Bool)] = [
        (.OBSCENE, false),
        (.WEATHER, false),
        (.COPYRIGHT, false),
        (.INSULT, false),
        (.REPEAT, false),
        (.MISC, false)
    ]
    
    public init(
        userManager: UserManager,
        userToken: String?,
        boardToken: String?,
        reportType: ReportType,
        fitftyRepository: FitftyRepository
    ) {
        self.userManager = userManager
        self.userToken = userToken
        self.boardToken = boardToken
        self.reportType = reportType
        self.fitftyRepository = fitftyRepository
    }
    
    private func getSelectedReport() -> [String] {
        guard let report = reports.filter({ $0.isSelected }).first?.detailReportType.englishDetailReport else {
            return []
        }
       return [report]
    }
    
}

extension DetailReportViewModel: DetailReportViewModelInput {
    var input: DetailReportViewModelInput { self }
    
    func didTapTitle(index: Int) {
        var reportCellModels = [ReportCellModel]()
        for i in 0..<reports.count {
            reports[i].isSelected =  i == index ? true : false
            reportCellModels.append(ReportCellModel.report(reports[i].detailReportType.koreanDetailReport, reports[i].isSelected))
        }
        
        currentState.send(.sections([
            DetailReportSection(
                sectionKind: .report,
                items: reportCellModels
            )
        ]))
    }
    
    func didTapReportButton() {
        if userManager.getCurrentGuestState() {
            currentState.send(.errorMessage("로그인이 필요합니다."))
        } else if reports.filter({ $0.isSelected }).count < 1 {
            currentState.send(.errorMessage("신고 사유를 선택해 주세요."))
        } else {
            report()
        }
    }
    
    func viewDidLoad() {
        var reportCellModels = [ReportCellModel]()
        for i in 0..<reports.count {
            reportCellModels.append(ReportCellModel.report(reports[i].detailReportType.koreanDetailReport, reports[i].isSelected))
        }
        currentState.send(.sections([
            DetailReportSection(
                sectionKind: .report,
                items: reportCellModels
            )
        ]))
    }
    
}

extension DetailReportViewModel: ViewModelType {
    
    public enum ViewModelState {
        case isLoading(Bool)
        case errorMessage(String)
        case completed(Bool)
        case sections([DetailReportSection])
    }
    
    public var state: AnyPublisher<ViewModelState, Never> { currentState.compactMap { $0 }.eraseToAnyPublisher() }
    
}

private extension DetailReportViewModel {
    
    func report() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                switch reportType {
                case .postReport:
                    guard let boardToken = boardToken else {
                        return
                    }
                    let request = PostReportRequest(
                        reportedBoardToken: boardToken,
                        type: getSelectedReport()
                    )
                    let response = try await self.fitftyRepository.report(request)
                    guard response.result == "SUCCESS" else {
                        return
                    }
                    self.currentState.send(.completed(true))
                    
                case .userReport:
                    guard let userToken = userToken else {
                        return
                    }
                    let request = UserReportRequest(
                        reportedUserToken: userToken,
                        type: getSelectedReport()
                    )
                    let response = try await self.fitftyRepository.report(request)
                    guard response.result == "SUCCESS" else {
                        return
                    }
                    self.currentState.send(.completed(true))
                }
                
            } catch {
                Logger.debug(error: error, message: "신고하기 실패")
                self.currentState.send(.errorMessage("신고에 알 수 없는 에러가 발생했습니다."))
            }
        }
    }
    
}
