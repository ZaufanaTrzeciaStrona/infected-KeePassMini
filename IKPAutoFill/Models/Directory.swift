struct Directory {
    let domain: String
    let username: String
    let pwd: String
    let hash: String
    let url: String
    let otpurl: String
    var otp: String
}

struct DirectorySection {
    let letter: String
    let constituents: [Directory]
}
