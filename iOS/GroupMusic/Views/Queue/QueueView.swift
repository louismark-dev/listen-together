//
//  QueueView.swift
//  GroupMusic-UI
//
//  Created by Louis on 2021-01-18.
//

import SwiftUI
import Combine

struct QueueView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    @EnvironmentObject var bannerController: BannerController
    @State private var nowPlayingIndicatorTimeout: Timer? = nil
    @State private var scrollViewReader: ScrollViewProxy?
    private let queueCellHeight: QueueCell.Height = QueueCell.Height(expanded: 120, collapsed: 80)
    private let queueSpacing: CGFloat = 20
    
    var body: some View {
        ScrollViewReader { (scrollView: ScrollViewProxy) in
            ScrollViewWithOffset(
                axes: [.vertical],
                showsIndicators: false,
                offsetChanged: {
                    self.setShowReturnToNowPlayingIndicator(withScrollOffset: $0, andTolerance: 20)
                }
            ) {
                VStack(spacing: self.queueSpacing) {
                    ForEach(self.playerAdapter.state.queue.state.queue, id: \.id) { (track: Track) in
                        // TODO: Handle case where attributes is null
                        if let attributes = track.attributes {
                            QueueCell(songName: attributes.name,
                                      artistName: attributes.artistName,
                                      artworkURL: attributes.artwork.url(forWidth: 400),
                                      indexInQueue: self.playerAdapter.state.queue.state.queue.firstIndex(of: track)!,
                                      height: queueCellHeight,
                                      expanded: false)
                                .id(track)
                        }
                    }
                }
            }
            .onChange(of: self.playerAdapter.state.queue.state.indexOfNowPlayingItem) { (indexOfNowPlayingItem: Int) in
                withAnimation {
                    scrollView.scrollTo(self.playerAdapter.state.queue.state.queue[indexOfNowPlayingItem], anchor: .top)
                }
            }
            .onChange(of: self.bannerController.scrollToTopOfQueue) { (shouldScrollToTopOfQueue: Bool) in
                guard (shouldScrollToTopOfQueue) else { return }
                withAnimation {
                    scrollView.scrollTo(self.playerAdapter.state.queue.state.nowPlayingItem, anchor: .top)
                }
                self.bannerController.scrollToTopOfQueue = false
            }
            .onAppear {
                self.scrollViewReader = scrollView
            }
        }
    }
    
    private func setShowReturnToNowPlayingIndicator(withScrollOffset scrollOffset:CGPoint, andTolerance tolerance: CGFloat) {
        self.nowPlayingIndicatorTimeout = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer: Timer) in
            // Offset of now playing = (playedItems * queueCellHeight.collapsed) + (playedItems * queueSpacing)
            let itemsPlayedCount: CGFloat = CGFloat(self.playerAdapter.state.queue.state.indexOfNowPlayingItem)
            let nowPlayingOffset = ((itemsPlayedCount * self.queueCellHeight.collapsed) + (itemsPlayedCount * self.queueSpacing))

            let scrollViewYOffset = -1 * scrollOffset.y

            let difference: CGFloat = abs(scrollViewYOffset - nowPlayingOffset)
            let showReturnToNowPlayingIndicator = (difference > tolerance)

            print("Now playing offset: \(nowPlayingOffset)")
            print("ScrollView Y offset: \(scrollViewYOffset)")
            print("Difference: \(difference)")
            print(showReturnToNowPlayingIndicator ? "Show return to now playing indicator" : "Don't show return to now playing indicator")

            withAnimation {
                if (showReturnToNowPlayingIndicator) {
                    self.bannerController.state.bannerState = .showReturnToNowPlayingBanner
                } else {
                    self.bannerController.state.bannerState = .none
                }
            }
        }
    }
}

struct ScrollViewWithOffset<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: Content
    
    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.offsetChanged = offsetChanged
        self.content = content()
    }
    
    var body: some View {
        SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geometry.frame(in: .named("scrollView")).origin
                )
            }.frame(width: 0, height: 0)
            content
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)
    }
}


struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

//struct QueueView_Previews: PreviewProvider {
//    static var previews: some View {
//        QueueView(selectedCell: .constant(0), queueItems: [
//            SampleData(artistName: "DaBaby", songName: "Practice", artworkName: "DaBaby"),
//            SampleData(artistName: "Lil Nas X", songName: "Holiday", artworkName: "LilNasX"),
//            SampleData(artistName: "NAV", songName: "Friends & Family", artworkName: "NAV"),
//            SampleData(artistName: "Juice WRLD & Young Thug", songName: "Bad Boy", artworkName: "YoungThug")
//        ])
//    }
//}
