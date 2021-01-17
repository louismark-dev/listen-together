//
//  AppleMusicQueueView.swift
//  GroupMusic
//
//  Created by Louis on 2021-01-02.
//

import SwiftUI

struct AppleMusicQueueView: View {
    @EnvironmentObject var playerAdapter: PlayerAdapter
    
    var body: some View {
        VStack {
            ForEach(self.playerAdapter.queue.state.queue) { queueItem in
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
