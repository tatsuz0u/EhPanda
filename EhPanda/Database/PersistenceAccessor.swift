//
//  PersistenceAccessor.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/07/05.
//

import SwiftUI
import CoreData

protocol PersistenceAccessor {
    var gid: String { get }
}

extension PersistenceAccessor {
    var manga: Manga {
        PersistenceController.fetchMangaNonNil(gid: gid)
    }
    var mangaDetail: MangaDetail? {
        PersistenceController.fetchMangaDetail(gid: gid)
    }
    var mangaState: MangaState {
        PersistenceController.fetchMangaStateNonNil(gid: gid)
    }
}

// MARK: Accessor Method
extension PersistenceController {
    static func fetchManga(gid: String) -> Manga? {
        var entity: Manga?
        dispatchMainSync {
            entity = fetch(entityType: MangaMO.self, gid: gid)?.toEntity()
        }
        return entity.forceUnwrapped
    }
    static func fetchMangaNonNil(gid: String) -> Manga {
        fetchManga(gid: gid) ?? Manga.empty
    }
    static func fetchMangaDetail(gid: String) -> MangaDetail? {
        var entity: MangaDetail?
        dispatchMainSync {
            entity = fetch(entityType: MangaDetailMO.self, gid: gid)?.toEntity()
        }
        return entity
    }
    static func fetchMangaStateNonNil(gid: String) -> MangaState {
        var entity: MangaState?
        dispatchMainSync {
            entity = fetchOrCreate(entityType: MangaStateMO.self, gid: gid).toEntity()
        }
        return entity.forceUnwrapped
    }
    static func fetchAppEnvNonNil() -> AppEnv {
        var entity: AppEnv?
        dispatchMainSync {
            entity = fetchOrCreate(entityType: AppEnvMO.self).toEntity()
        }
        return entity.forceUnwrapped
    }
    static func fetchMangaHistory() -> [Manga] {
        let predicate = NSPredicate(format: "lastOpenDate != nil")
        let sortDescriptor = NSSortDescriptor(
            keyPath: \MangaMO.lastOpenDate, ascending: false
        )
        return fetch(
            entityType: MangaMO.self,
            predicate: predicate,
            findBeforeFetch: false,
            sortDescriptors: [sortDescriptor]
        ).map({ $0.toEntity() })
    }

    static func fetch<MO: NSManagedObject>(
        entityType: MO.Type, gid: String,
        findBeforeFetch: Bool = true,
        commitChanges: ((MO?) -> Void)? = nil
    ) -> MO? {
        fetch(
            entityType: entityType,
            predicate: NSPredicate(
                format: "gid == %@", gid
            ),
            findBeforeFetch: findBeforeFetch,
            commitChanges: commitChanges
        )
    }
    static func fetchOrCreate<MO: GalleryIdentifiable>(
        entityType: MO.Type, gid: String
    ) -> MO {
        fetchOrCreate(
            entityType: entityType,
            predicate: NSPredicate(
                format: "gid == %@", gid
            )
        ) { managedObject in
            managedObject?.gid = gid
        }
    }

    static func add(mangas: [Manga]) {
        for manga in mangas {
            let storedMO = fetch(
                entityType: MangaMO.self,
                gid: manga.gid
            ) { managedObject in
                managedObject?.title = manga.title
                managedObject?.rating = manga.rating
                managedObject?.language = manga.language?.rawValue
            }
            if storedMO == nil {
                manga.toManagedObject(in: shared.container.viewContext)
            }
        }
        saveContext()
    }

    static func add(detail: MangaDetail) {
        let storedMO = fetch(
            entityType: MangaDetailMO.self,
            gid: detail.gid
        ) { managedObject in
            managedObject?.isFavored = detail.isFavored
            managedObject?.archiveURL = detail.archiveURL
            managedObject?.jpnTitle = detail.jpnTitle
            managedObject?.likeCount = detail.likeCount
            managedObject?.pageCount = detail.pageCount
            managedObject?.sizeCount = detail.sizeCount
            managedObject?.sizeType = detail.sizeType
            managedObject?.rating = detail.rating
            managedObject?.ratingCount = detail.ratingCount
            managedObject?.torrentCount = Int16(detail.torrentCount)
        }
        if storedMO == nil {
            detail.toManagedObject(in: shared.container.viewContext)
        }
        saveContext()
    }

    static func mangaCached(gid: String) -> Bool {
        PersistenceController.checkExistence(
            entityType: MangaMO.self,
            predicate: NSPredicate(
                format: "gid == %@", gid
            )
        )
    }

    static func updateLastOpenDate(gid: String) {
        update(entityType: MangaMO.self, gid: gid) { mangaMO in
            mangaMO.lastOpenDate = Date()
        }
    }
    static func update(appEnvMO: ((AppEnvMO) -> Void)) {
        update(entityType: AppEnvMO.self, createIfNil: true, commitChanges: appEnvMO)
    }

    // MARK: MangaState
    static func update(gid: String, mangaStateMO: @escaping ((MangaStateMO) -> Void)) {
        update(entityType: MangaStateMO.self, gid: gid, createIfNil: true, commitChanges: mangaStateMO)
    }
    static func update(fetchedState: MangaState) {
        update(gid: fetchedState.gid) { mangaStateMO in
            mangaStateMO.tags = fetchedState.tags.toData()
            mangaStateMO.previews = fetchedState.previews.toData()
            mangaStateMO.comments = fetchedState.comments.toData()
        }
    }
    static func update(gid: String, aspectBox: [Int: CGFloat]) {
        update(gid: gid) { mangaStateMO in
            mangaStateMO.aspectBox = aspectBox.toData()
        }
    }
    static func update(gid: String, readingProgress: Int) {
        update(gid: gid) { mangaStateMO in
            mangaStateMO.readingProgress = Int16(readingProgress)
        }
    }
    static func update(gid: String, userRating: Float) {
        update(gid: gid) { mangaStateMO in
            mangaStateMO.userRating = userRating
        }
    }
    static func update(gid: String, pageNum: PageNumber, contents: [MangaContent]) {
        update(gid: gid) { mangaStateMO in
            mangaStateMO.currentPageNum = Int16(pageNum.current)
            mangaStateMO.pageNumMaximum = Int16(pageNum.maximum)

            let newContents = contents.sorted(by: { $0.tag < $1.tag })
            var storedContents = mangaStateMO.contents?
                .toObject() ?? [MangaContent]()

            if storedContents.isEmpty {
                mangaStateMO.contents = newContents.toData()
            } else {
                newContents.forEach { content in
                    if !storedContents.contains(content) {
                        storedContents.append(content)
                    }
                }
                mangaStateMO.contents = storedContents.toData()
            }
        }
    }
}
