import Foundation

enum Constants {
    static let accessKey = "CLwMRKntNob0cLn-F_zqKgEi6arX6tfq5pSJnM8tqug"
    static let secretKey = "Z9xRQwyJ1X9iW-AO9vBCatSUFmO2a5hUZnrGpy6BuJM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            preconditionFailure("Invalid Unsplash API base URL")
        }
        return url
    }()
}
