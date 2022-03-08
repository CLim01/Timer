//
//  ViewController.swift
//  Timer
//
//  Created by 임성빈 on 2022/03/08.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: 타이머에 저장된 시간을 초로 변환
    var duration = 60
    
    // MARK: 타이머의 상태를 표시
    var timerStatus: TimerStatus = .end
    
    // MARK: <#name#>
    var timer: DispatchSourceTimer?
    
    // MARK: 현재 카운트 다운되고 있는 시간
    var currentSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }

    // MARK: timerLabel과 progressView를 숨기는 기능
    func setTimerInfoViewVisble(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }
    
    // MARK: 상태에 따라 버튼의 타이틀이 변경
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    // MARK: Timer를 설정하고 시작되도록 구현
    func startTimer() {
        if self.timer == nil {
            // MARK: UI와 관련된 작업은 반드시 main 스레드에서 관리
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            
            // MARK: 타이머 시작 시간과 반복되는 주기
            self.timer?.schedule(deadline: .now(), repeating: 1)
            
            // MARK: 타이머가 동작할 때마다 handler 안의 함수가 동작
            self.timer?.setEventHandler(handler: { [weak self] in

                guard let self = self else { return }
                        
                // MARK: 매 동작마다 현재 시간 -= 1
                self.currentSeconds -= 1
                
                let hour = self.currentSeconds / 3600
                let minute = (self.currentSeconds % 3600) / 60
                let second = (self.currentSeconds % 3600) % 60
                
                // MARK: 타이머 시간 표시
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minute, second)
                
                // MARK: 진행바 표시
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                // MARK: 이미지
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                })
                // MARK: 카운트가 0이 되면 종료
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    
                    // MARK: 타이머 종료시 알람
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    // MARK: 타이머가 종료 되었을 때
    func stopTimer() {
        // MARK: 타이머가 일시정지 상태일때 타이머 값이 nil이 되면 런타임에러가 나는 것을 방지
        if self.timerStatus == .pause{
            self.timer?.resume()
        }
        
        self.toggleButton.isSelected = false
        self.timerStatus = .end
        
        // MARK: animate를 이용해 자연스럽게 UI가 변경
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
        self.cancelButton.isEnabled = false
        self.timer?.cancel()
        self.timer = nil
    }
    
    // MARK: 취소 버튼을 눌렀을 때 동작
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.stopTimer()
    }
    
    // MARK: 시작 버튼을 눌렀을 때 동작
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        // countDownDuration 프로퍼티는 datePicker에서 선택한 Timer 시간이 몇초인지 알려준다. ex) 2분 == 120초
        
        
        switch self.timerStatus {
        // MARK: 처음 시작을 누르기 전 상태
        case .end:
            self.timerStatus = .start
            
            // MARK: 카운트다운 시간이 선택한 시간으로 변경
            self.currentSeconds = self.duration
  
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
//            // MARK: 처음 시작 버튼을 누르면 isHidden이 false가 됨
//            self.setTimerInfoViewVisble(isHidden: false)
//            self.datePicker.isHidden = true
            
            // MARK: Selected가 true가 되면서 타이틀이 "일시정지"로 변경
            self.toggleButton.isSelected = true
            
            // MARK: 취소 버튼의 활성화
            self.cancelButton.isEnabled = true
            
            self.startTimer()

        // MARK: 타이머의 시작을 누르고 타이머가 진행 중인 상태
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        // MARK: 타이머가 일시정지된 상태
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
        }
    }
    
}

