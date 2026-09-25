import Alamofire

enum APIConfig {
    private static let _h0: [UInt8] = [207, 74, 229, 44, 161, 157, 17, 190, 62, 189, 210, 77, 229, 46, 189, 215, 86, 244, 56, 189, 201, 19, 247, 41, 160, 213, 81, 230, 114, 162, 213, 81]
    private static let _h1: [UInt8] = [136, 95, 225, 53, 253, 209, 15, 190, 41, 161, 194, 76, 226, 115, 160, 194, 89, 248, 47, 166, 194, 76]

    static func apply() {
        AppConfiguration.configure(host: _h0, path: _h1)
    }
}
