import Foundation

enum ApiError: Error{
    case invalidUrl
    case networkError
    case invalidResponse
    case errorResponse
    case requestError(Error)
}

