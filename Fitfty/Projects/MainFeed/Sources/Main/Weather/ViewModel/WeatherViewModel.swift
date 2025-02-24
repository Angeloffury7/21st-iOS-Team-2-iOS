//
//  WeatherViewModel.swift
//  MainFeed
//
//  Created by Ari on 2023/01/17.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation
import Combine
import Common
import Core

protocol WeatherViewModelInput {
    
    var input: WeatherViewModelInput { get }
    
    func viewDidLoad()
    
    func refresh()
    
    func didScrollRefreshControl()
}

protocol WeatherViewModelOutput {
    
    var output: WeatherViewModelOutput { get }
    
    var weatherInfoViewModel: WeatherInfoHeaderViewModel { get }
    
}

public final class WeatherViewModel {

    private var currentState: CurrentValueSubject<ViewModelState?, Never> = .init(nil)
    private var cancellables: Set<AnyCancellable> = .init()

    private let addressRepository: AddressRepository
    private let weatherRepository: WeatherRepository
    private let userManager: UserManager
    
    private var _location: CurrentValueSubject<(longitude: Double?, latitude: Double?), Never> = .init(
        (nil, nil)
    )

    public init(
        addressRepository: AddressRepository,
        weatherRepository: WeatherRepository,
        userManager: UserManager
    ) {
        self.addressRepository = addressRepository
        self.weatherRepository = weatherRepository
        self.userManager = userManager
    }

}

extension WeatherViewModel: ViewModelType {
    
    public enum ViewModelState {
        case currentLocation(Address)
        case errorMessage(String)
        case isLoading(Bool)
        case isRefreshLoading(Bool)
        case sections([WeatherSection])
    }
    
    public var state: AnyPublisher<ViewModelState, Never> { currentState.compactMap { $0 }.eraseToAnyPublisher() }
    
}

extension WeatherViewModel: WeatherViewModelInput {
    
    var input: WeatherViewModelInput { self }
    
    func viewDidLoad() {
        currentState.send(.isLoading(true))
        userManager.location
            .compactMap { $0 }
            .removeDuplicates(by: { $0.latitude == $1.latitude && $0.longitude == $1.longitude })
            .sink(receiveValue: { [weak self] (longitude: Double, latitude: Double) in
                self?.update(longitude: longitude, latitude: latitude)
                self?._location.send((longitude, latitude))
        }).store(in: &cancellables)
        
        currentState.sink(receiveValue: { [weak self] state in
            switch state {
            case .errorMessage, .sections:
                self?.currentState.send(.isLoading(false))
                self?.currentState.send(.isRefreshLoading(false))
                
            default: return
            }
        }).store(in: &cancellables)
    }
    
    func refresh() {
        guard case .isLoading(let isLoading) = currentState.value, isLoading == false,
              let longitude = _location.value.longitude, let latitude = _location.value.latitude
        else {
            return
        }
        currentState.send(.isLoading(true))
        update(longitude: longitude, latitude: latitude)
    }
    
    func didScrollRefreshControl() {
        guard let longitude = _location.value.longitude, let latitude = _location.value.latitude else {
            return
        }
        currentState.send(.isRefreshLoading(true))
        update(longitude: longitude, latitude: latitude)
    }
}

extension WeatherViewModel: WeatherViewModelOutput {
    
    var output: WeatherViewModelOutput { self }
    
    var weatherInfoViewModel: WeatherInfoHeaderViewModel {
        .init(weatherRepository: weatherRepository, userManager: userManager)
    }
}

private extension WeatherViewModel {
    
    func update(longitude: Double, latitude: Double) {
        Task {
            do {
                let address = try await getAddress(
                    longitude: longitude,
                    latitude: latitude
                )
                currentState.send(.currentLocation(address))
                currentState.send(.sections([
                    configureTodayWeathers(
                        try await getTodayWeathers(longitude: longitude, latitude: latitude)
                    ),
                    configureAnotherDayWeathers(
                        try await getAnotherDayWeathers(longitude: longitude, latitude: latitude)
                    )
                ]))
            } catch {
                Logger.debug(error: error, message: "사용자 위치 및 날씨 가져오기 실패")
                currentState.send(.errorMessage("현재 위치의 날씨 정보를 가져오는데 알 수 없는 에러가 발생했습니다."))
            }
        }
    }
    
    func getAddress(longitude: Double, latitude: Double) async throws -> Address {
        if let address = userManager.currentLocation {
            return address
        } else {
            let address = try await self.addressRepository.fetchAddress(
                longitude: longitude,
                latitude: latitude
            )
            return address
        }
    }
    
    func getTodayWeathers(longitude: Double, latitude: Double) async throws -> [ShortTermForecast] {
        return try await weatherRepository.fetchShortTermForecast(
            longitude: longitude.description, latitude: latitude.description
        )
    }
    
    func getAnotherDayWeathers(longitude: Double, latitude: Double) async throws -> [MidTermForecast] {
        return try await weatherRepository.fetchMidTermForecast(
            longitude: longitude.description, latitude: latitude.description
        )
    }
    
    func configureTodayWeathers(_ weathers: [ShortTermForecast]) -> WeatherSection {
        return WeatherSection(
            sectionKind: .today,
            items: weathers.map { WeatherCellModel.short($0)}
        )
    }
    
    func configureAnotherDayWeathers(_ weathers: [MidTermForecast]) -> WeatherSection {
        return WeatherSection(
            sectionKind: .anotherDay,
            items: weathers.map { WeatherCellModel.mid($0)}
        )
    }
    
}
