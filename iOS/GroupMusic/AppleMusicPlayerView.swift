//
//  AppleMusicPlayerView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicPlayerView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    let socketManager: GMSockets
    
    init(socketManager: GMSockets = GMSockets.sharedInstance) {
        self.socketManager = socketManager
    }
    
    var body: some View {
        VStack {
            Text(self.playerAdapter.state.queue.state.nowPlayingItem?.attributes?.name ?? "No name available")
            HStack {
                Button(action: self.skipToPreviousItem) {
                    Image(systemName: "backward.fill")
                }
                Spacer()
                Button(action: {
                    togglePlayback()
                }) {
                    Image(systemName: (self.playerAdapter.state.playbackState != .playing) ? "play.fill" : "pause.fill")
                }
                Spacer()
                Button(action: self.skipToNextItem) {
                    Image(systemName: "forward.fill")
                }
            }
            .foregroundColor(.black)
            .background(Color.green)
        }
    }
    
    private func togglePlayback() {
        if self.playerAdapter.state.playbackState != .playing {
            self.playerAdapter.play(completion: {
                do {
                    try self.socketManager.emitPlayEvent()
                } catch {
                    fatalError(error.localizedDescription)
                }
            })
        } else {
            self.playerAdapter.pause(completion: {
                do {
                    try self.socketManager.emitPauseEvent()
                } catch {
                    fatalError(error.localizedDescription)
                }
            })
        }
    }
    
    private func skipToNextItem() {
        self.playerAdapter.skipToNextItem(completion: {
            do {
                try self.socketManager.emitForwardEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    private func skipToPreviousItem() {
        self.playerAdapter.skipToPreviousItem(completion: {
            do {
                try self.socketManager.emitPreviousEvent()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
}

struct AppleMusicPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicPlayerView()
    }
}
