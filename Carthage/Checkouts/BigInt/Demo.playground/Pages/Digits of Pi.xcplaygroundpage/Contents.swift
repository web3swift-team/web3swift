//: [Previous](@previous)
import BigInt
//: ## Let's calculate the first thousand digits of π
//:
//: A fun application of BigInts is generating the digits of π.
//: Let's implement [Jeremy Gibbon's spigot algorithm][spigot] as an infinite `GeneratorType`. 
//: This is a quite slow algorithm, but it makes up for it with its grooviness factor.
//:
//: [spigot]: http://www.cs.ox.ac.uk/jeremy.gibbons/publications/spigot.pdf
func digitsOfPi() -> AnyIterator<Int> {
    var q: BigUInt = 1
    var r: BigUInt = 180
    var t: BigUInt = 60
    var i: UInt64 = 2 // Works until digit #826_566_842
    return AnyIterator {
        let u: UInt64 = 3 * (3 * i + 1) * (3 * i + 2)
        let y = (q.multiplied(byDigit: 27 * i - 12) + 5 * r) / (5 * t)
        (q, r, t) = (
            10 * q.multiplied(byDigit: i * (2 * i - 1)),
            10 * (q.multiplied(byDigit: 5 * i - 2) + r - y * t).multiplied(byDigit: u),
            t.multiplied(byDigit: u))
        i += 1
        return Int(y[0])
    }
}
//: Well, that was surprisingly easy. Does it work? You bet:
let digits = digitsOfPi().prefix(999).reduce("") { $0 + String($1) }
//: [Next](@next)
