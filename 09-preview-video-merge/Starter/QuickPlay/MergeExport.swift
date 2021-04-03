//
//  MergeExport.swift
//  QuickPlay
//
//  Created by 🤨 on 3/04/21.
//

import Foundation
import AVKit
import os

class MergeExport {
  let logger = Logger(subsystem: "com.edserweb.mergeexport", category: "mergeexport")
  var previewUrl: URL?
  var videoURLS = [URL]()
  
  func previewMerge() -> AVPlayerItem {
    let videoAssets = videoURLS.map { AVAsset(url: $0) }
    let composition = AVMutableComposition()
    if let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
       , let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) {
      var startTime = CMTime.zero
      for asset in videoAssets {
        do {
          try videoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration),
                                         of: asset.tracks(withMediaType: .video)[0],
                                         at: startTime)
          try audioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration),
                                         of: asset.tracks(withMediaType: .video)[0],
                                         at: startTime)
        } catch {
          logger.error("error creating track")
        }
        startTime = CMTimeAdd(startTime, asset.duration)
      }
    }
    return AVPlayerItem(asset: composition)
  }
}
