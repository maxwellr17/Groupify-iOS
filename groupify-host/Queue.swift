//
//  Queue.swift
//  groupify-host
//
//  Created by Noah Rubin on 1/20/18.
//  Copyright © 2018 Noah Rubin. All rights reserved.
//

import Foundation

class Queue {
    public static let instance = Queue()
    var queue: [Song] = []
    var deviceToken: String!
    var groupifyID: String!
    var session: SPTSession!
    var defaultPlaylist: SPTPartialPlaylist!
    var explicit: Bool!
    var shuffleDefaultPlaylist: Bool!
}

struct Song {
    let title: String
    let artists: [String]
    let album: String
    let artwork: String
    let explicit: Bool
    let uri: String
    
    init(track: SPTPlaybackTrack) {
        self.title = track.name
        self.artists = [track.artistName]
        self.album = track.albumName
        self.artwork = track.albumCoverArtURL!
        self.explicit = false
        self.uri = track.uri
    }
    
    init(data: [String: AnyObject]) {
        self.title = data["title"] as! String
        self.artists = data["artists"] as! [String]
        self.album = data["album"] as! String
        self.artwork = data["artwork"] as! String
        self.explicit = data["explicit"] as! Bool
        self.uri = data["uri"] as! String
    }
}
