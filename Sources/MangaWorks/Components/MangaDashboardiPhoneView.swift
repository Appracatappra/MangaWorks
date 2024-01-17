//
//  SwiftUIView.swift
//  
//
//  Created by Kevin Mullins on 1/2/24.
//

import SwiftUI
import SwiftletUtilities
import SwiftUIKit
import LogManager
import GraceLanguage
import SwiftUIGamepad

/// Draws a simulated iPhone 14 Pro Max that is displayed on the landscape view of a manga page.
public struct MangaDashboardiPhoneView: View {
    
    // MARK: - Initializers
    /// Creates a new instance.
    public init() {
        
    }
    
    /// Creates a new instance.
    /// - Parameters:
    ///   - isGamepadConnected: if `true` a gamepad is connected to the device that the app is running on.
    ///   - weatherIcon: The simulated weather icon.
    ///   - temperature: The simulated temperature.
    public init(isGamepadConnected: Bool = false, weatherIcon: String = "hurricane.circle.fill", temperature: String = "75º") {
        self.isGamepadConnected = isGamepadConnected
        self.weatherIcon = weatherIcon
        self.temperature = temperature
    }
    
    // MARK: - Properties
    /// if `true` a gamepad is connected to the device that the app is running on.
    public var isGamepadConnected:Bool = false
    
    /// The simulated weather icon.
    public var weatherIcon:String = "hurricane.circle.fill"
    
    /// The simulated temperature.
    public var temperature:String = "75º"
    
    /// Holds the current time.
    @State private var currentTime:String = "12:00"
    
    /// A timer used to update the time every 60 seconds.
    @State private var timer:Timer? = nil
    
    // MARK: - Computed Properties
    /// The current day.
    private var day:String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E d"
        return dateFormatter.string(from: now)
    }
    
    /// The gamepad battery level.
    private var batteryLevel:Int {
        return Int(GamepadManager.gampadBatteryLevel * 100.0)
    }
    
    /// The gamepad battery level icon.
    private var batteryIcon:String {
        if GamepadManager.gamepadIsBatteryCharging {
            return "battery.100.bolt"
        } else if batteryLevel < 25 {
            return "battery.0"
        } else if batteryLevel > 24 && batteryLevel < 50 {
            return "battery.25"
        } else if batteryLevel > 49 && batteryLevel < 75 {
            return "battery.50"
        } else if batteryLevel > 74 && batteryLevel < 100 {
            return "battery.75"
        }
        
        return "battery.100"
    }
    
    /// The scale to display the iPhone body.
    private var imageScale:Float {
        if HardwareInformation.isPad {
            switch HardwareInformation.screenWidth {
            case 566:
                return 0.55
            case 683:
                return 0.70
            default:
                return 0.60
            }
        } else {
            return 0.70
        }
    }
    
    /// Adjusts the font size based on the device the app is running on.
    private var fontAdjustment: CGFloat {
        if HardwareInformation.isPad {
            switch HardwareInformation.screenWidth {
            case 566:
                return 4
            case 683:
                return 0
            default:
                return 4
            }
        } else {
            return 0
        }
    }
    
    /// The content width based on the device the app is running on.
    private var boxWidth:CGFloat {
        if HardwareInformation.isPad {
            switch HardwareInformation.screenWidth {
            case 566:
                return 245
            case 683:
                return 300
            default:
                return 270
            }
        } else {
            return 300
        }
    }
    
    // MARK: - Control Body
    /// The body of the control.
    public var body: some View {
        ScaledImageView(imageURL: MangaWorks.urlTo(resource: "iPhone14ProMax", withExtension: "png"), scale: imageScale)
        .shadow(color: .black, radius: CGFloat(20.0))
        .overlay {
            VStack(spacing: 5.0) {
                HStack(spacing: 5.0) {
                    Text("\(day) ")
                        .font(.system(size: 16 - fontAdjustment))
                        .foregroundColor(.white)
                    
                    Image(systemName: weatherIcon)
                        .font(.system(size: 14 - fontAdjustment))
                        .foregroundColor(.white)
                    
                    Text(temperature)
                        .font(.system(size: 16 - fontAdjustment))
                        .foregroundColor(.white)
                }
                .padding(.top, 70)
                
                Text(currentTime)
                    .font(ComicFonts.stormfaze.ofSize(64 - Float(fontAdjustment)))
                    .foregroundColor(.white)
                
                HStack(spacing: 5.0) {
                    if isGamepadConnected {
                        Text("\(GamepadManager.gamepadName) ")
                            .font(.system(size: 18 - fontAdjustment))
                            .foregroundColor(.white)
                        
                        Image(systemName: batteryIcon)
                            .font(.system(size: 18 - fontAdjustment))
                            .foregroundColor(.white)
                        
                        if batteryLevel < 0 {
                            Text("?")
                                .font(.system(size: 18 - fontAdjustment))
                                .foregroundColor(.white)
                        } else {
                            Text("\(batteryLevel) %")
                                .font(.system(size: 18 - fontAdjustment))
                                .foregroundColor(.white)
                        }
                    } else {
                        Text("Gamepad Not Connected")
                            .font(.system(size: 18 - fontAdjustment))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: boxWidth)
                
                if let notification = MangaBook.shared.simulatediPhoneNotification {
                    MangaDashboardNotificationView(iconName: notification.icon, title: notification.title, description: notification.description, boxWidth: boxWidth, fontAsjustment: fontAdjustment)
                        .padding(.top, 50.0)
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Setup time view
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
                updateTime()
            }
        }
        .onDisappear {
            // Release the timer
            if let timer {
                timer.invalidate()
            }
        }
    }
    
    // MARK: - Functions
    /// Sets the current time displayed in the iPhone view.
    private func updateTime() {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        currentTime = dateFormatter.string(from: now)
    }
}

#Preview {
    MangaDashboardiPhoneView()
}
