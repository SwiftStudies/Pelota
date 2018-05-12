public extension String {
    public subscript(_ range:Range<Int>)->String{
        let lower = index(startIndex, offsetBy: range.lowerBound)
        let upper = index(startIndex, offsetBy: range.upperBound)
        return String(self[lower..<upper])
    }
}

public func require<T>(_ optional:T?,or message:String)->T{
    if let unwrapped = optional {
        return unwrapped
    }
    fatalError(message)
}
