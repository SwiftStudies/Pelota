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


public struct Position : Decodable{
    public let x : Float
    public let y : Float
    
    public init(x:Float, y:Float){
        self.x = x
        self.y = y
    }
    
    public init(x:Int, y:Int){
        self.init(x: Float(x), y: Float(y))
    }
}
