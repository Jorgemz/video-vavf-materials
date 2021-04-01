//
//  Thumbnail.swift
//  QuickPlay
//
//  Created by 🤨 on 31/03/21.
//

import SwiftUI
import AVFoundation

struct Thumbnail: View {
  
  let thumbanailImage: UIImage?
  
  init(url: URL) {
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    var time = asset.duration
    time.value = min(time.value, 2)
    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      thumbanailImage = UIImage(cgImage: imageRef)
    } catch {
      thumbanailImage = nil
    }
  }
  
    var body: some View {
      if let thumbnail = thumbanailImage {
        Image(uiImage: thumbnail)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 100, height: 100, alignment: .center)
          .padding(.trailing)
      } else {
        EmptyView()
      }
    }
}
