public enum GitError: Error {
    // case repositoryNotFound
    // case invalidRepository
    // case unknownError(String)
    case cloneFailed(reason: String)
}