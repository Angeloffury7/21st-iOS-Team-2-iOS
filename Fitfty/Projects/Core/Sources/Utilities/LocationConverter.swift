//
//  LocationConverter.swift
//  Core
//
//  Created by Ari on 2023/01/21.
//  Copyright © 2023 Fitfty. All rights reserved.
//

import Foundation

struct MapGridData {
    /// 사용할 지구반경  [ km ]
    let radius = 6371.00877
    /// 사용할 지구반경  [ km ]
    let grid = 5.0
    /// 표준위도       [degree]
    let slat1 = 30.0
    /// 표준위도       [degree]
    let slat2 = 60.0
    /// 기준점의 경도   [degree]
    let olon = 126.0
    /// 기준점의 위도   [degree]
    let olat = 38.0
    /// 기준점의 X좌표  [격자거리] // 210.0 / grid
    let xCoordinate = 42.0
    /// 기준점의 Y좌표  [격자거리] // 675.0 / grid
    let yCoordinate = 135.0
}

final class LocationConverter {
    static let shared = LocationConverter()
    
    private let map: MapGridData = MapGridData()

    private let pi: Double = .pi
    private let degrad: Double = .pi / 180.0
    private let raddeg: Double = 180.0 / .pi

    /// 지구 반경 [km]
    private var re: Double
    /// 표준 위도 1 [degree]
    private var slat1: Double
    /// 표준 위도 2 [degree]
    private var slat2: Double
    /// 기준점의 경도 [degree]
    private var olon: Double
    /// 기준점의 위도 [degree]
    private var olat: Double
    /// 표준위도 간의 비율
    private var sn: Double
    /// 표준위도 간의 비율에 따른 계산값
    private var sf: Double
    /// 기준점의 위도에 따른 계산값
    private var ro: Double
    
    private init() {
        re = map.radius / map.grid
        slat1 = map.slat1 * degrad
        slat2 = map.slat2 * degrad
        olon = map.olon * degrad
        olat = map.olat * degrad
        
        sn = tan(pi * 0.25 + slat2 * 0.5) / tan(pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        sf = tan(pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        ro = tan(pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)
    }
    
    func grid(longitude: Double, latitude: Double) -> (x: Int, y: Int) {
        let (longitude, latitude) = check(longitude: longitude, latitude: latitude)
        var ra: Double = tan(pi * 0.25 + latitude * degrad * 0.5)
        ra = re * sf / pow(ra, sn)
        var theta: Double = longitude * degrad - olon
        if theta > pi {
            theta -= 2.0 * pi
        }
        if theta < -pi {
            theta += 2.0 * pi
        }
        theta *= sn
        let x: Double = ra * sin(theta) + map.xCoordinate
        let y: Double = ro - ra * cos(theta) + map.yCoordinate
        return (Int(x + 1.5), Int(y + 1.5))
    }
    
    private func check(longitude: Double, latitude: Double) -> (longitude: Double, latitude: Double) {
        if longitude <= 130, longitude >= 127 && latitude <= 38, latitude >= 35 {
            return (longitude, latitude)
        } else {
            return (LocationManager.Constant.defaultLongitude, LocationManager.Constant.defaultLatitude)
        }
    }
}
