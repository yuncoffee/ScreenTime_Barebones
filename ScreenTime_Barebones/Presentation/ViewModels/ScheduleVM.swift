//
//  ScheduleVM.swift
//  ScreenTime_Barebones
//
//  Created by Yun Dongbeom on 2023/08/09.
//

import Foundation
import FamilyControls

enum ScheduleSectionInfo {
    case time
    case apps
    case revoke
    
    var header: String {
        switch self {
        case .time:
            return "setup Time"
        case .apps:
            return "setup Apps"
        case .revoke:
            return "Revoke Authorization"
        }
    }
    
    var footer: String {
        switch self {
        case .time:
            return "시작 시간과 종료 시간을 설정하여 앱 사용을 제한하고자 하는\n스케쥴 시간을 설정할 수 있습니다."
        case .apps:
            return "변경하기 버튼을 눌러 선택한 시간 동안 사용을 제한하고 싶은\n앱 및 웹 도메인을 선택할 수 있습니다."
        case .revoke:
            return ""
        }
    }
}

class ScheduleVM: ObservableObject {
    // MARK: - 스케쥴 설정을 위한 멤버 변수 [현재 시간, + 15분]
    @Published var times: [Date] = [Date(), Date() + 900]
    // MARK: - 사용자가 설정한 앱/도메인을 담고 있는 멤버 변수
    @Published var selection = FamilyActivitySelection()
    @Published var isFamilyActivitySectionActive = false
    @Published var isSaveAlertActive = false
    @Published var isRevokeAlertActive = false
}

extension ScheduleVM {
    // MARK: - FamilyActivity Sheet 열기
    /// 호출 시 사용자가 제한하고자 하는 기기에 설치한 앱 혹은 웹 도메인을
    /// 선택할 수 있는 FamilyActivitySelection을 엽니다.
    func showFamilyActivitySelection() {
        isFamilyActivitySectionActive = true
    }
    
    // MARK: - ScreenTime API 권한 삭제 alert 열기
    /// 호출 시 권한을 제거할 수 있는 alert을 열어 앱 사용을 위해
    /// 부여했던 ScreenTIme API 권한을 제거할 수 있습니다.
    func showRevokeAlert() {
        isRevokeAlertActive = true
    }
    
    /// 사용자가 선택한 앱 & 도메인 토큰이 비어있는지 확인하기 위한 메서드입니다.
    func isSelectionEmpty() -> Bool {
        selection.applicationTokens.isEmpty &&
        selection.categoryTokens.isEmpty &&
        selection.webDomainTokens.isEmpty
    }
    
    // MARK: - 스케쥴 저장
    /// 설정한 시간 DeviceActivityManager를 통해 전달하여 설정한 시간을 모니터링할 수 있습니다.
    /// 모니터링을 등록하면 DeviceActivityMonitorExtension를 활용해 특정 시점의 이벤트를 감지할 수 있습니다.
    func saveSchedule() {
        let startTime = Calendar.current.dateComponents([.hour, .minute], from: times[0])
        let endTime = Calendar.current.dateComponents([.hour, .minute], from: times[1])
        
        DeviceActivityManager.shared.handleStartDeviceActivityMonitoring(
            startTime: startTime,
            endTime: endTime
        )
        
        isSaveAlertActive = true
    }
}