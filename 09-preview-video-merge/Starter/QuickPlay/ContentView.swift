///// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import PhotosUI
import AVKit

struct ContentView: View {

  @State var isSheetPresented = false
  @State var videos = [URL]()
  @State var sheetMode: SheetMode = .picker
  @State var selectedVideo = -1
  
  @ObservedObject var merger = MergeExport()
  
  enum SheetMode {
    case picker
    case video
    case merge
    case preview
  }

  var body: some View {
    VStack {
      List {
        ForEach(0 ..< videos.count, id: \.self) { index in
          HStack {
            Thumbnail(url: videos[index])
            Text("Video Clip \(index + 1)")
          }
          .onTapGesture {
            isSheetPresented = true
            sheetMode = .video
            selectedVideo = index
          }
        }
        if let exportUrl = merger.exportUrl {
          HStack {
            Thumbnail(url: exportUrl)
            Text("Merget Export")
          }
          .onTapGesture {
            selectedVideo = -1
            isSheetPresented = true
            sheetMode = .video
          }
        }
      }
      HStack {
        HStack {
          Button {
            isSheetPresented = true
            sheetMode = .picker
          } label: {
            Image(systemName: "video.badge.plus")
              .font(.largeTitle)
          }
        }
        .padding(.leading)
        Spacer()
        Button {
          merger.videoURLS = videos
          isSheetPresented = true
          sheetMode = .preview
        } label: {
          Image(systemName: "list.and.film")
            .font(.largeTitle)
        }
        .disabled(videos.count == 0)
        .padding(.trailing)
        Spacer()
        Button {
          merger.videoURLS = videos
          merger.mergeAndExxportVideo()
        } label: {
          Image(systemName: "film")
            .font(.largeTitle)
        }
        .disabled(videos.count == 0)
        .padding(.trailing)
      }
      .sheet(isPresented: $isSheetPresented) {
        switch(sheetMode) {
        case .picker:
          PhotoPicker(isPresented: $isSheetPresented, videos: $videos)
        case .video:
          AVMoviePlayer(url: (selectedVideo == -1) ? merger.exportUrl! : videos[selectedVideo])
        case .merge:
          AVMoviePlayer(urls: videos)
        case .preview:
          AVMoviePlayer(playerItem: merger.previewMerge())
        }
      }
    }
  }
}
