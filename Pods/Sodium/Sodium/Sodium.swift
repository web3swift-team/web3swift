import Foundation
import libsodium

public class Sodium {
    public let box = Box()
    public let secretBox = SecretBox()
    public let genericHash = GenericHash()
    public let pwHash = PWHash()
    public let randomBytes = RandomBytes()
    public let shortHash = ShortHash()
    public let sign = Sign()
    public let utils = Utils()
    public let keyExchange = KeyExchange()
    public let auth = Auth()
    public let stream = Stream()
    public let keyDerivation = KeyDerivation()
    public let secretStream = SecretStream()

    private static let once: Void = {
        if sodium_init() < 0 {
            fatalError("Failed to initialize libsodium")
        }
    }()

    public init() {
        _ = Sodium.once
    }
}
