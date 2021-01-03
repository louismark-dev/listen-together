//
//  AppleMusicQueueView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicQueueView: View {
    @ObservedObject var appleMusicPlayer: GMAppleMusicPlayer
    @ObservedObject var appleMusicQueue: GMAppleMusicQueue // TODO: This should not be a dependency of this struct
    
    init(appleMusicPlayer: GMAppleMusicPlayer = GMAppleMusicPlayer(),
         appleMusicQueue: GMAppleMusicQueue = GMAppleMusicQueue.sharedInstance) {
        self.appleMusicPlayer = appleMusicPlayer
        self.appleMusicQueue = appleMusicQueue
    }
    
    var body: some View {
        VStack {
            ForEach(self.appleMusicQueue.queue) { queueItem in
                Text(queueItem.attributes?.name ?? "Name not available")
            }
        }
    }
}

struct AppleMusicQueueView_Previews: PreviewProvider {
    static var previews: some View {
        AppleMusicQueueView()
    }
}
