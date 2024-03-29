//
//  PlaybackProgressView2.swift
//  GroupMusic
//
//  Created by Louis on 2021-05-11.
//

import SwiftUI

struct PlaybackProgressView2: View {
    @State var config: Configuration = Configuration()
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @StateObject var playbackProgressMonitor: PlaybackProgressMonitor = PlaybackProgressMonitor()
    
      var body: some View {
        VStack {
            CustomSlider(config: self.$config, playbackFraction: self.$playbackProgressMonitor.playbackFraction, range: 0...100)
                .environmentObject(self.playbackProgressMonitor)
            TimestampView(config: self.$config,
                          playbackFraction: self.$playbackProgressMonitor.playbackFraction,
                          playbackProgressTimestamp: self.$playbackProgressMonitor.playbackProgressTimestamp,
                          playbackDurationTimestamp: self.$playbackProgressMonitor.playbackDurationTimestamp)
                .padding(.top, 4)
        }
        .onAppear {
            self.playbackProgressMonitor.startMonitoring(withPlayerAdapter: self.playerAdapter)
        }
      }
    
    struct Configuration {
        var knobScale: CustomSlider.KnobScale = .normal
        var animationDuration: Double = 0.15
        var foregroundColor: Color = Color.white
    }
}

struct TimestampView: View {
    @Binding var config: PlaybackProgressView2.Configuration
    @Binding var playbackFraction: Double
    @Binding var playbackProgressTimestamp: String
    @Binding var playbackDurationTimestamp: String
    @State private var offsetConfig: OffsetConfiguration = .none
    
    private let yOffset: CGFloat = 20.0
    
    var body: some View {
        HStack {
            Text(self.playbackProgressTimestamp)
                .offset(x: 0, y: (self.offsetConfig == .leading) ? self.yOffset : 0)
            Spacer()
            Text(self.playbackDurationTimestamp)
                .offset(x: 0, y: (self.offsetConfig == .trailing) ? self.yOffset : 0)
        }
        .foregroundColor(self.config.foregroundColor)
        .font(Font.system(.footnote, design: .rounded).weight(.semibold))
        .onChange(of: self.playbackFraction, perform: { (value: Double) in
            self.setOffset(forSliderValue: CGFloat(self.playbackFraction))
        })
        .onChange(of: self.config.knobScale, perform: { _ in
            self.setOffset(forSliderValue: CGFloat(self.playbackFraction))
        })
    }
    
    private func setOffset(forSliderValue sliderValue: CGFloat) {
        withAnimation(Animation.easeInOut(duration: self.config.animationDuration), {
            if (sliderValue < 20 && self.config.knobScale == .large) {
                self.offsetConfig = .leading
            } else if (sliderValue > 80 && self.config.knobScale == .large) {
                self.offsetConfig = .trailing
            } else {
                self.offsetConfig = .none
            }
        })
    }
    
    enum OffsetConfiguration {
        case leading
        case trailing
        case none
    }
}

struct CustomSlider: View {
    @EnvironmentObject var playbackProgressMonitor: PlaybackProgressMonitor
    
    @Binding var config: PlaybackProgressView2.Configuration
    @Binding var playbackFraction: Double
    
    @State var lastOffset: CGFloat = 0
    
    var range: ClosedRange<CGFloat>
    var leadingOffset: CGFloat = 0
    var trailingOffset: CGFloat = 0
    let progressBarHeight: CGFloat = 3.0
    
    @State var knobSize: CGSize = CGSize(width: 10, height: 10)
        
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 100)
                    .frame(height: self.progressBarHeight)
                    .foregroundColor(self.config.foregroundColor)
                    .opacity(0.3)
                HStack {
                    RoundedRectangle(cornerRadius: 100)
                        .frame(width: min(CGFloat(self.playbackFraction) / 100, 1.0) * geometry.size.width, height: self.progressBarHeight)
                        .foregroundColor(self.config.foregroundColor)
                        .opacity(0.6)
                    Spacer()
                }
                HStack {
                    RoundedRectangle(cornerRadius: 50)
                        .frame(width: self.knobSize.width, height: self.knobSize.height)
                        .contentShape(Rectangle())
                        .scaleEffect(self.config.knobScale.rawValue)
                        .foregroundColor(self.config.foregroundColor)
                        .offset(x: CGFloat(self.playbackFraction).map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset)))
                        .overlay(Rectangle()
                                    .frame(width: 44, height: 44)
                                    .opacity(0.0001)
                                    .offset(x: CGFloat(self.playbackFraction).map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset)))
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                self.setKnobScale(to: .large)
                                                if abs(value.translation.width) < 0.1 {
                                                    self.lastOffset = CGFloat(self.playbackFraction).map(from: self.range, to: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset))
                                                }
                                                
                                                let sliderPos = max(0 + self.leadingOffset, min(self.lastOffset + value.translation.width, geometry.size.width - self.knobSize.width - self.trailingOffset))
                                                let sliderVal = sliderPos.map(from: self.leadingOffset...(geometry.size.width - self.knobSize.width - self.trailingOffset), to: self.range)
                                                
                                                self.playbackProgressMonitor.userScrubbingStarted()
                                                self.playbackFraction = Double(sliderVal)
                                                self.playbackProgressMonitor.setTimestamp(forPlaybackFraction: self.playbackFraction)
                                            }
                                            .onEnded({ _ in
                                                self.playbackProgressMonitor.userScrubbingEnded(withPlaybackFraction: self.playbackFraction)
                                                self.setKnobScale(to: .normal)
                                            })
                                            
                                )
                        )
                    Spacer()
                }
            }
        }
        .frame(height: 5)
    }
    
    private func setKnobScale(to scale: KnobScale) {
        withAnimation(Animation.easeInOut(duration: self.config.animationDuration), {
            self.config.knobScale = scale
        })
    }
    
    enum KnobScale: CGFloat {
        case normal = 1.0
        case large = 3.0
    }
}


extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
//struct PlaybackProgressView2_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaybackProgressView2()
//    }
//}
