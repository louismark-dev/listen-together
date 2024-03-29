//
//  PlaybackProgressView.swift
//  GroupMusic
//
//  Created by Louis Mark on 2021-01-23.
//

import SwiftUI

struct PlaybackProgressView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @State var playbackFraction: Double = 0.01
    @State var playbackProgressTimestamp: String = "0:00"
    @State var playbackDurationTimestamp: String = "0:00"
    // Only accept state updates when application is in the foreground. Otherwise SwiftUI will repeatedly produce the following error in the console:
    // onChange(of: Double) action tried to update multiple times per frame."
    @State var acceptStateUpdates: Bool = true
    
    let notificationCenter: NotificationCenter
    let enteringBackgroundPublisher: NotificationCenter.Publisher
    let enteringForegroundPublisher: NotificationCenter.Publisher
        
    init(notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
        self.enteringBackgroundPublisher = self.notificationCenter.publisher(for: UIApplication.willResignActiveNotification)
        self.enteringForegroundPublisher = self.notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
    }
    
    var body: some View {
        Group {
            if (self.acceptStateUpdates) {
                InnerView(playbackFraction: self.$playbackFraction,
                          playbackProgressTimestamp: self.$playbackProgressTimestamp,
                          playbackDurationTimestamp: self.$playbackDurationTimestamp)
                    // We only want to monitor for changes when in foreground
                    .onChange(of: self.playerAdapter.state.playbackPosition.playbackFraction, perform: self.setPlaybackProgress)
                    .onChange(of: self.playerAdapter.state.playbackPosition.currentPlaybackTime, perform: self.setPlaybackProgressTimestamp)
                    .onChange(of: self.playerAdapter.state.playbackPosition.playbackDuration, perform: self.setPlaybackDurationTimestamp)
            } else {
                InnerView(playbackFraction: self.$playbackFraction,
                          playbackProgressTimestamp: self.$playbackProgressTimestamp,
                          playbackDurationTimestamp: self.$playbackDurationTimestamp)
            }
        }
        .onReceive(self.enteringBackgroundPublisher, perform: { _ in
            self.acceptStateUpdates = false
        })
        .onReceive(self.enteringForegroundPublisher, perform: { _ in
            self.acceptStateUpdates = true
        })
    }
    
    private struct InnerView: View {
        @EnvironmentObject var playerAdapter: PlayerAdapter
        @Binding var playbackFraction: Double
        @Binding var playbackProgressTimestamp: String
        @Binding var playbackDurationTimestamp: String
        
        var body: some View {
            VStack {
                ProgressView(value: self.playbackFraction)
                HStack {
                    Text(self.playbackProgressTimestamp)
                    Spacer()
                    Text(self.playbackDurationTimestamp)
                }
                .font(.custom("Arial Rounded MT Bold", size: 16, relativeTo: .title))
                .foregroundColor(.white)
                .opacity(0.9)
            }
        }
    }
    
    /// Sets the visual progress of the ProgressView. When playbackFraction is 0.0, the ProgressView will be set to 0.01, so that a progress bar is still displayed
    /// - Parameter playbackFraction: Fraction played
    private func setPlaybackProgress(playbackFraction : Double) {
        if (playbackFraction == 0.0) {
            self.playbackFraction = 0.01
        } else {
            self.playbackFraction = playbackFraction
        }
    }
    
    private func setPlaybackProgressTimestamp(currentPlaybackTime: TimeInterval) {
        self.playbackProgressTimestamp = convertToTimestamp(time: currentPlaybackTime)
    }
    
    private func setPlaybackDurationTimestamp(playbackDuration: TimeInterval) {
        self.playbackDurationTimestamp = convertToTimestamp(time: playbackDuration)
    }
    
    private func convertToTimestamp(time: TimeInterval) -> String {
        let minutes = Int(floor(time / 60))
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        var secondsString: String {
            if (seconds < 10 ) {
                return "0\(seconds)"
            }
            return "\(seconds)"
        }
        return "\(minutes):\(secondsString)"
    }
}

struct PlaybackProgressView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackProgressView()
    }
}
