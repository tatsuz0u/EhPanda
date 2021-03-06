//
//  MangaStateMO+CoreDataProperties.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/07/09.
//

import CoreData

extension MangaStateMO: GalleryIdentifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MangaStateMO> {
        NSFetchRequest<MangaStateMO>(entityName: "MangaStateMO")
    }

    @NSManaged public var aspectBox: Data?
    @NSManaged public var comments: Data?
    @NSManaged public var contents: Data?
    @NSManaged public var currentPageNum: Int16
    @NSManaged public var gid: String
    @NSManaged public var pageNumMaximum: Int16
    @NSManaged public var previews: Data?
    @NSManaged public var readingProgress: Int16
    @NSManaged public var tags: Data?
    @NSManaged public var userRating: Float
}
