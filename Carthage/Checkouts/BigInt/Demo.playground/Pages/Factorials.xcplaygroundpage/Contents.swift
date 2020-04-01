//: [Previous](@previous)
import Foundation
import BigInt
//: The canonical way to demo big integers is with the factorial function. Here is a fancy definition for it:
func fact(_ n: Int) -> BigInt {
    return (1 ... n).map { BigInt($0) }.reduce(BigInt(1), *)
}

let f1 = fact(1)
let f2 = fact(2)
let f3 = fact(3)
let f4 = fact(4)
let f10 = fact(10)
let f100 = fact(100)
let f1000 = fact(1000)
//: That last value seems quite large. Just how many decimal digits is it? Let's convert it to a `String` to find out.
let decimal = String(f1000)
let digitCount = decimal.characters.count
//: Wow. 2500 digits is peanuts for `BigInt`, but Xcode's playground tech isn't designed to perform well with much more loop iterations, so let's stay at this level for now.
let ff2 = f1000 * f1000
String(ff2).characters.count

let ff4 = ff2 * ff2
String(ff4).characters.count

let ff8 = ff4 * ff4
String(ff8).characters.count
//: That last operation multiplied two 10000-digit numbers; you may have noticed it took a couple of seconds to compute that value. Converting such huge values to decimal isn't particularly cheap, either.
//:
//: [Next](@next)
