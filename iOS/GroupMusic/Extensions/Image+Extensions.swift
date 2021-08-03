//
//  Image+Extensions.swift
//  GroupMusic
//
//  Created by Louis on 2021-07-13.
//

import SwiftUI

extension Image {
    
    static let ui = UI()
   
    struct UI {
        let stop_fill = Image(systemName: "stop.fill")
        let person_fill = Image(systemName: "person.fill")
        let person_3_fill = Image(systemName: "person.3.fill")
        let plus = Image(systemName: "plus")
        let play_fill = Image(systemName: "play.fill")
        let pause_fill = Image(systemName: "pause.fill")
        let backward_fill = Image(systemName: "backward.fill")
        let forward_fill = Image(systemName: "forward.fill")
        let text_insert = Image(systemName: "text.insert")
        let text_append = Image(systemName: "text.append")
        let xmark = Image(systemName: "xmark")
        let _repeat = Image(systemName: "repeat")
    }
}
