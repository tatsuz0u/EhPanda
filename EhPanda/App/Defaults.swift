//
//  Defaults.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 2/11/22.
//

import UIKit
import Foundation

struct Defaults {
    struct FrameSize {
        static var slideMenuWidth: CGFloat {
            if isPadWidth {
                return max(windowW - 500, 300)
            } else {
                return max(windowW - 90, 250)
            }
        }
    }
    struct ImageSize {
        static let rowScale: CGFloat = 8/11
        static let avatarScale: CGFloat = 1/1
        static let headerScale: CGFloat = 8/11
        static let previewScale: CGFloat = 32/45
        static let contentHScale: CGFloat = 7/10

        static let rowW: CGFloat = rowH * rowScale
        static let rowH: CGFloat = 110
        static let avatarW: CGFloat = 100
        static let avatarH: CGFloat = 100
        static let headerW: CGFloat = headerH * headerScale
        static let headerH: CGFloat = 150
        static let previewW: CGFloat = previewH * previewScale
        static let previewH: CGFloat = 200
    }
    struct Cookie {
        static let null = "null"
        static let expired = "expired"
        static let mystery = "mystery"

        static let igneous = "igneous"
        static let ipbMemberId = "ipb_member_id"
        static let ipbPassHash = "ipb_pass_hash"
    }
    struct DateFormat {
        static let publish = "yyyy-MM-dd HH:mm"
        static let torrent = "yyyy-MM-dd HH:mm"
        static let comment = "dd MMMM yyyy, HH:mm"
    }
    struct FilePath {
        static let logs = "logs"
        static let ehpandaLog = "EhPanda.log"
    }
    struct Response {
        static let hathClientNotFound = "You must have a H@H client assigned to your account to use this feature."
        static let hathClientNotOnline = "Your H@H client appears to be offline. Turn it on, then try again."
        static let invalidResolution = "The requested gallery cannot be downloaded with the selected resolution."
    }
    struct URL {
        // Domains
        static var host: String {
            galleryHost == .exhentai ? exhentai : ehentai
        }
        static let ehentai = "https://e-hentai.org/"
        static let exhentai = "https://exhentai.org/"
        static let forum = "https://forums.e-hentai.org/"
        static let login = merge(urls: [forum + index, loginAct])
        static let magnet = "magnet:?xt=urn:btih:"

        // Functional Pages
        static let tag = "tag/"
        static let popular = "popular"
        static let watched = "watched"
        static let mytags = "mytags"
        static let api = "api.php"
        static let news = "news.php"
        static let index = "index.php"
        static let uconfig = "uconfig.php"
        static let favorites = "favorites.php"
        static let gallerypopups = "gallerypopups.php"
        static let gallerytorrents = "gallerytorrents.php"

        static let contentPage = "p="
        static let token = "t="
        static let gid = "gid="
        static let page = "page="
        static let from = "from="
        static let favcat = "favcat="
        static let showuser = "showuser="
        static let fSearch = "f_search="

        static let showComments = "hc=1"
        static let loginAct = "act=Login"
        static let addfavAct = "act=addfav"
        static let ignoreOffensive = "nw=always"
        static let listCompact = "inline_set=dm_l"
        static let previewNormal = "inline_set=ts_m"
        static let previewLarge = "inline_set=ts_l"
        static let rowsLimit = "inline_set=tr_4"

        // Filter
        static let fCats = "f_cats="
        static let advSearch = "advsearch=1"
        static let fSnameOn = "f_sname=on"
        static let fStagsOn = "f_stags=on"
        static let fSdescOn = "f_sdesc=on"
        static let fStorrOn = "f_storr=on"
        static let fStoOn = "f_sto=on"
        static let fSdt1On = "f_sdt1=on"
        static let fSdt2On = "f_sdt2=on"
        static let fShOn = "f_sh=on"
        static let fSrOn = "f_sr=on"
        static let fSrdd = "f_srdd="
        static let fSpOn = "f_sp=on"
        static let fSpf = "f_spf="
        static let fSpt = "f_spt="
        static let fSflOn = "f_sfl=on"
        static let fSfuOn = "f_sfu=on"
        static let fSftOn = "f_sft=on"
    }
}

// MARK: Request
extension Defaults.URL {
    // Fetch
    static func searchList(keyword: String, filter: Filter) -> String {
        merge(urls: [
            host, fSearch
            + keyword.urlEncoded()
        ]
        + applyFilters(filter: filter)
        )
    }
    static func moreSearchList(
        keyword: String,
        filter: Filter,
        pageNum: String,
        lastID: String
    ) -> String {
        merge(
            urls: [
                host,
                fSearch + keyword.urlEncoded(),
                page + pageNum,
                from + lastID
            ]
            + applyFilters(filter: filter)
        )
    }
    static func frontpageList() -> String {
        host
    }
    static func moreFrontpageList(pageNum: String, lastID: String) -> String {
        merge(urls: [host, page + pageNum, from + lastID])
    }
    static func popularList() -> String {
        host + popular
    }
    static func watchedList() -> String {
        host + watched
    }
    static func moreWatchedList(pageNum: String, lastID: String) -> String {
        merge(urls: [host + watched, page + pageNum, from + lastID])
    }
    static func favoritesList(favIndex: Int) -> String {
        if favIndex == -1 {
            return host + favorites
        } else {
            return merge(urls: [host + favorites, favcat + "\(favIndex)"])
        }
    }
    static func moreFavoritesList(favIndex: Int, pageNum: String, lastID: String) -> String {
        if favIndex == -1 {
            return merge(urls: [host + favorites, page + pageNum, from + lastID])
        } else {
            return merge(urls: [host + favorites, favcat + "\(favIndex)", page + pageNum, from + lastID])
        }
    }
    static func mangaDetail(url: String) -> String {
        merge(urls: [url, showComments])
    }
    static func mangaTorrents(gid: String, token: String) -> String {
        merge(urls: [host + gallerytorrents, Defaults.URL.gid + gid, Defaults.URL.token + token])
    }
    static func associatedItemsRedir(keyword: AssociatedKeyword) -> String {
        if let title = keyword.title {
            return similarGallery(keyword: title)
        } else {
            return assciatedItems(keyword: (keyword.category ?? "", keyword.content ?? ""))
        }
    }
    static func assciatedItems(keyword: (String, String)) -> String {
        merge(keyword: keyword, pageNum: nil, lastID: nil)
    }
    static func similarGallery(keyword: String) -> String {
        merge(urls: [host, fSearch + keyword.urlEncoded()])
    }
    static func moreAssociatedItemsRedir(keyword: AssociatedKeyword, lastID: String, pageNum: String) -> String {
        if let title = keyword.title {
            return moreSimilarGallery(keyword: title, pageNum: pageNum, lastID: lastID)
        } else {
            return moreAssociatedItems(
                keyword: (keyword.category ?? "", keyword.content ?? ""),
                pageNum: pageNum, lastID: lastID
            )
        }
    }
    static func moreAssociatedItems(keyword: (String, String), pageNum: String, lastID: String) -> String {
        merge(keyword: keyword, pageNum: pageNum, lastID: lastID)
    }
    static func moreSimilarGallery(keyword: String, pageNum: String, lastID: String) -> String {
        merge(urls: [
                host,
                fSearch + keyword.urlEncoded(),
                page + pageNum,
                from + lastID
        ])
    }
    static func mangaContents(detailURL: String) -> String {
        detailURL
    }

    // Account Associated Operations
    static func addFavorite(gid: String, token: String) -> String {
        merge(urls: [host + gallerypopups, Defaults.URL.gid + gid, Defaults.URL.token + token, addfavAct])
    }
    static func userID() -> String {
        forum + index
    }
    static func userInfo(uid: String) -> String {
        merge(urls: [forum + index, showuser + uid])
    }
    static func greeting() -> String {
        ehentai + news
    }

    // Misc
    static func contentPage(url: String, pageNum: Int) -> String {
        merge(urls: [url, contentPage + "\(pageNum)"])
    }
    static func magnet(hash: String) -> String {
        magnet + hash
    }
    static func ehAPI() -> String {
        host + api
    }
    static func ehFavorites() -> String {
        host + favorites
    }
    static func ehConfig() -> String {
        host + uconfig
    }
    static func ehMyTags() -> String {
        host + mytags
    }
}

// MARK: Filter
private extension Defaults.URL {
    static func applyFilters(filter: Filter) -> [String] {
        var filters = [String]()

        var category = 0
        category += filter.doujinshi.isFiltered ? Category.doujinshi.value : 0
        category += filter.manga.isFiltered ? Category.manga.value : 0
        category += filter.artistCG.isFiltered ? Category.artistCG.value : 0
        category += filter.gameCG.isFiltered ? Category.gameCG.value : 0
        category += filter.western.isFiltered ? Category.western.value : 0
        category += filter.nonH.isFiltered ? Category.nonH.value : 0
        category += filter.imageSet.isFiltered ? Category.imageSet.value : 0
        category += filter.cosplay.isFiltered ? Category.cosplay.value : 0
        category += filter.asianPorn.isFiltered ? Category.asianPorn.value : 0
        category += filter.misc.isFiltered ? Category.misc.value : 0

        if ![0, 1023].contains(category) {
            filters.append(fCats + "\(category)")
        }

        if !filter.advanced { return filters }
        filters.append(advSearch)

        if filter.galleryName { filters.append(fSnameOn) }
        if filter.galleryTags { filters.append(fStagsOn) }
        if filter.galleryDesc { filters.append(fSdescOn) }
        if filter.torrentFilenames { filters.append(fStorrOn) }
        if filter.onlyWithTorrents { filters.append(fStoOn) }
        if filter.lowPowerTags { filters.append(fSdt1On) }
        if filter.downvotedTags { filters.append(fSdt2On) }
        if filter.expungedGalleries { filters.append(fShOn) }

        if filter.minRatingActivated,
           [2, 3, 4, 5].contains(filter.minRating)
        {
            filters.append(fSrOn)
            filters.append(fSrdd + "\(filter.minRating)")
        }

        if filter.pageRangeActivated,
           let minPages = Int(filter.pageLowerBound),
           let maxPages = Int(filter.pageUpperBound),
           minPages > 0 && maxPages > 0 && minPages <= maxPages
        {
            filters.append(fSpOn)
            filters.append(fSpf + "\(minPages)")
            filters.append(fSpt + "\(maxPages)")
        }

        if filter.disableLanguage { filters.append(fSflOn) }
        if filter.disableUploader { filters.append(fSfuOn) }
        if filter.disableTags { filters.append(fSftOn) }

        return filters
    }
}

// MARK: Tools
private extension Defaults.URL {
    static func merge(urls: [String]) -> String {
        let firstTwo = urls.prefix(2)
        let remainder = urls.suffix(from: 2)

        var joinedArray = [String]()
        joinedArray.append(firstTwo.joined(separator: "?"))

        if remainder.count > 0 {
            joinedArray.append(remainder.joined(separator: "&"))
        }

        if joinedArray.count > 1 {
            return joinedArray.joined(separator: "&")
        } else {
            return joinedArray.joined()
        }
    }
    static func merge(keyword: (String, String), pageNum: String?, lastID: String?) -> String {
        guard let pageNum = pageNum, let lastID = lastID else {
            return host + tag + "\(keyword.0):\(keyword.1.urlEncoded())"
        }
        return merge(urls: [host + tag + "\(keyword.0):\(keyword.1.urlEncoded())/\(pageNum)", from + lastID])
    }
}
