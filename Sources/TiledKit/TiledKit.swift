internal func require<T>(_ optional:T?,or message:String)->T{
    if let unwrapped = optional {
        return unwrapped
    }
    fatalError(message)
}
