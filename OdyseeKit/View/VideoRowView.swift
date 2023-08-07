//
//  VideoRowView.swift
//  OdyseeKit
//
//  Created by Alsey Coleman Miller on 8/6/23.
//

import Foundation
import SwiftUI
import LBRY

public struct VideoRowView: View {
    
    let item: Item
    
    public init(
        item: Item
    ) {
        self.item = item
    }
    
    public var body: some View {
        HStack {
            
            // thumbnail
            CachedAsyncImage(url: item.thumbnail, scale: 2.0, content: { image in
                image
                    .resizable()
                    .cornerRadius(8)
            }, placeholder: {
                Color.gray
            })
            .frame(
                width: thumbnailSize.width,
                height: thumbnailSize.height
            )
            
            // text
            VStack(alignment: .leading, spacing: 16) {
                // title
                Text(verbatim: item.title)
                    .lineLimit(2)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // channel details
                if let channel = item.channel {
                    HStack(spacing: 16) {
                        // channel image
                        CachedAsyncImage(url: channel.thumbnail, scale: 2.0, content: { image in
                            image
                                .resizable()
                        }, placeholder: {
                            Color.gray
                        })
                        .cornerRadius(channelThumbnailSize.width / 2)
                        .frame(
                            width: channelThumbnailSize.width,
                            height: channelThumbnailSize.height
                        )
                        .padding()
                        
                        // channel name
                        VStack(alignment: .leading, spacing: 6) {
                            Text(verbatim: channel.name)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let relativeTimestamp {
                                Text(verbatim: relativeTimestamp)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // description
                if let description = item.descriptionText {
                    Text(verbatim: description)
                        .lineLimit(2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

public extension VideoRowView {
    
    struct Item {
        
        public let title: String
        
        public let thumbnail: URL?
        
        public let descriptionText: String?
        
        public let timestamp: Date?
        
        public let channel: ChannelInfo?
    }
    
    struct ChannelInfo {
        
        public let name: String
        
        public let thumbnail: URL?
    }
}

public extension VideoRowView.Item {
    
    init(claim: LBRY.Claim) {
        self.title = claim.value?.title ?? claim.name ?? "Unnamed Video"
        self.thumbnail = claim.value?.thumbnail?.url
        self.descriptionText = claim.value?.description
        self.timestamp = claim.timestamp.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        self.channel = claim.signingChannel.map { .init(signingChannel: $0) }
    }
}

public extension VideoRowView.ChannelInfo {
    
    init(signingChannel claim: LBRY.Claim) {
        self.name = claim.name ?? ""
        self.thumbnail = claim.value?.thumbnail?.url
    }
}

public extension VideoRowView {
    
    init(
        claim: LBRY.Claim
    ) {
        let item = Item(claim: claim)
        self.init(item: item)
    }
}

private extension VideoRowView {
    
    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var thumbnailSize: CGSize {
        #if os(tvOS)
        CGSize(width: 470, height: 270)
        #else
        CGSize(width: 150, height: 100)
        #endif
    }
    
    var channelThumbnailSize: CGSize {
        #if os(tvOS)
        CGSize(width: 60, height: 60)
        #else
        CGSize(width: 20, height: 20)
        #endif
    }
    
    var relativeTimestamp: String? {
        item.timestamp.map { Self.relativeDateTimeFormatter.localizedString(for: $0, relativeTo: Date()) }
    }
}

#if DEBUG

@available(iOS 16.0, *)
struct VideoRowView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            List(Claim.mock, id: \.claimId) {
                VideoRowView(claim: $0)
            }
        }
    }
}

#endif
