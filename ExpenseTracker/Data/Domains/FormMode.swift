import Foundation
import CoreData

enum FormMode: Identifiable {
    case create
    case edit(TransactionEntity)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let item):
            return item.objectID.uriRepresentation().absoluteString
        }
    }
}

