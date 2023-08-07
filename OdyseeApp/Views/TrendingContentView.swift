//
//  TrendingContentView.swift
//  
//
//  Created by Alsey Coleman Miller on 8/6/23.
//

import Foundation
import SwiftUI
import Odysee
import LBRY
import OdyseeKit

struct TrendingContentView: View {
    
    @EnvironmentObject
    private var store: Store
    
    @State
    private var state: ViewState = .loading
    
    var body: some View {
        VStack {
            switch state {
            case .loading:
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            case let .error(error):
                VStack {
                    Text(verbatim: error)
                    Button("Retry") {
                        Task(priority: .userInitiated) {
                            await resetData()
                        }
                    }
                }
            case let .content(sections):
                List(sections) { section in
                    Section(section.title) {
                        ForEach(section.items, id: \.claimId) { claim in
                            NavigationLink(destination: {
                                EmptyView()
                            }, label: {
                                VideoRowView(claim: claim)
                            })
                        }
                    }
                }
                .refreshable {
                    await reloadData()
                }
            }
        }
        .onAppear {
            Task(priority: .userInitiated) {
                await reloadData()
            }
        }
    }
}

private extension TrendingContentView {
    
    enum ViewState {
        
        case loading
        case error(String)
        case content([ViewSection])
    }
    
    struct ViewSection: Identifiable {
        
        let id: String
        
        let title: String
        
        let items: [LBRY.Claim]
    }
}

private extension TrendingContentView {
    
    func resetData() async {
        state = .loading
        await reloadData()
    }
    
    func reloadData() async {
        do {
            let content = try await store.fetchContent()
            let categories = content.categories
                .sorted(by: { $0.value.sortOrder ?? 0 < $1.value.sortOrder ?? 0 })
            let sections = await withTaskGroup(of: ViewSection?.self, returning: [ViewSection].self) { taskGroup in
                for category in categories {
                    var time = Int64(Date().timeIntervalSince1970)
                    time = time - (60 * 60 * 24 * 180)
                    let releaseTime = String(format: ">%d", time)
                    let request = ClaimSearchRequest(
                        claimType: [.stream, .repost],
                        streamTypes: [.audio, .video],
                        page: 1,
                        pageSize: 20,
                        releaseTime: [releaseTime],
                        limitClaimsPerChannel: 1,
                        notTags: nil,
                        channelIds: category.value.channelIds,
                        notChannelIds: nil,
                        orderBy: ["release_time"]
                    )
                    print(category.key, request)
                    taskGroup.addTask {
                        do {
                            let response = try await URLSession.shared.response(for: request)
                            let items = response.items
                            if items.isEmpty {
                                return nil
                            }
                            return ViewSection(
                                id: category.key,
                                title: category.value.label,
                                items: items
                            )
                        }
                        catch {
                            await store.log("Unable to fetch items for \(category.key). \(error.localizedDescription)")
                            #if DEBUG
                            print(error)
                            #endif
                            return nil
                        }
                    }
                }
                var results = [ViewSection]()
                results.reserveCapacity(categories.count)
                for await result in taskGroup.compactMap({ $0 }) {
                    results.append(result)
                }
                return results
            }
            self.state = .content(sections)
        }
        catch {
            self.state = .error(error.localizedDescription)
        }
    }
}

#if DEBUG
struct TrendingContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TrendingContentView()
        }
        .environmentObject(Store())
    }
}
#endif
