//
//  AppleMusicQueueView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicQueueView: View {
    @ObservedObject var appleMusicQueue: GMAppleMusicQueue // TODO: This should not be a dependency of this struct
    
    init(appleMusicQueue: GMAppleMusicQueue = GMAppleMusicQueue.sharedInstance) {
        self.appleMusicQueue = appleMusicQueue
    }
    
    var body: some View {
        VStack {
            ForEach(self.appleMusicQueue.state.queue) { queueItem in
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
