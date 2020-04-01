//: [Previous](@previous)
import Foundation
import BigInt
//: # Generating Large Prime Numbers
//:
//: `BigUInt` has an `isPrime()` method that does a [Miller-Rabin Primality Test][mrpt]. Let's use
//: this to create a function that finds the next prime number after any integer:
//:
//: [mrpt]: https://en.wikipedia.org/wiki/Miller%2dRabin_primality_test
func findNextPrime(after integer: BigUInt) -> BigUInt {
    var candidate = integer
    repeat {
        candidate.increment()
    } while !candidate.isPrime()
    return candidate
}

findNextPrime(after: 100)
findNextPrime(after: 1000)
findNextPrime(after: 10000)
findNextPrime(after: 100000000000)
findNextPrime(after: BigUInt(1) << 64)
findNextPrime(after: BigUInt(1) << 128)
findNextPrime(after: BigUInt(1) << 256)
//: [Next](@next)
