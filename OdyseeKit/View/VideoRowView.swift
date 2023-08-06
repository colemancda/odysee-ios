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
    
    public let claim: LBRY.Claim
    
    public let showChannelName: Bool
    
    public init(
        claim: LBRY.Claim,
        showChannelName: Bool = true
    ) {
        self.claim = claim
        self.showChannelName = showChannelName
    }
    
    public var body: some View {
        HStack {
            
            // thumbnail
            CachedAsyncImage(url: claim.value?.thumbnail?.url, scale: 2.0, content: { image in
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
                if let name = claim.value?.title {
                    Text(verbatim: name)
                        .lineLimit(2)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                // channel details
                if showChannelName,
                   let thumbnailURL = claim.signingChannel?.value?.thumbnail?.url,
                   let channelName = claim.signingChannel?.normalizedName,
                   let timestamp = self.relativeTimestamp {
                    HStack(spacing: 16) {
                        // channel image
                        CachedAsyncImage(url: thumbnailURL, scale: 2.0, content: { image in
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
                            Text(verbatim: channelName)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(verbatim: timestamp)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // description
                if let description = claim.value?.description {
                    Text(verbatim: description)
                        .lineLimit(2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private extension VideoRowView {
    
    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    var thumbnailSize: CGSize {
        CGSize(width: 470, height: 270)
    }
    
    var channelThumbnailSize: CGSize {
        CGSize(width: 60, height: 60)
    }
    
    var timestamp: Date? {
        claim.timestamp.map { Date(timeIntervalSince1970: TimeInterval($0)) }
    }
    
    var relativeTimestamp: String? {
        timestamp.map { Self.relativeDateTimeFormatter.localizedString(for: $0, relativeTo: Date()) }
    }
}

#if DEBUG

struct VideoRowView_Preview: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            List(Claim.mock, id: \.claimId) {
                VideoRowView(claim: $0)
            }
        }
    }
}

#endif
