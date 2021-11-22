//: [Previous](@previous)
import Foundation
import BigInt
//: # RSA cryptography
//:
//: Another useful thing to have is a function that finds a random n-bit prime number:
func generatePrime(ofWidth width: Int) -> BigUInt {
    while true {
        var random = BigUInt.randomInteger(withExactWidth: width)
        random |= BigUInt(1)
        if random.isPrime() {
            return random
        }
    }
}
//: For instance, here are two random 1024-bit prime numbers:
let p = generatePrime(ofWidth: 1024)
let q = generatePrime(ofWidth: 1024)
//: We know their product isn't prime, and `BigInt`'s primality test agrees:
let n = p * q
n.isPrime()
//: But we'd be in serious trouble if we had to get `p` and `q` back by factoring `n`---and this observation is
//: what makes RSA work. 
//: 
//: So let's derive a public/private RSA keypair out of these two primes:
//:
//: (Note though that in a real RSA cryptosystem, primes are chosen much more carefully.)
let phi = (p - 1) * (q - 1)
let e: BigUInt = 65537
let d = e.inverse(phi)!

d * e % phi

typealias Key = (modulus: BigUInt, exponent: BigUInt)

let publicKey: Key = (n, e)
let privateKey: Key = (n, d)
//: Given a key and a message, encryption is simply a modular exponentiation:
//: (Again, this is an oversimplification. In the real RSA system, the message is first transformed by a
//: [complex padding scheme][oaep].)
//: 
//: [oaep]: https://en.wikipedia.org/wiki/Optimal_asymmetric_encryption_padding
func encrypt(_ message: BigUInt, key: Key) -> BigUInt {
    return message.power(key.exponent, modulus: key.modulus)
}
//: Let's try encrypting some message with the public key.
let secret: BigUInt = BigUInt("Arbitrary precision arithmetic is fun!".data(using: .utf8)!)

let cyphertext = encrypt(secret, key: publicKey)
//: Well that was easy. In theory, we can decrypt the cyphertext by simply encrypting it with the private key.
//: But does it really work? Yep:
let plaintext = encrypt(cyphertext, key: privateKey)

let message = String(data: plaintext.serialize(), encoding: .utf8)
//: Isn't that awesome?
//:
//: [Next](@next)
