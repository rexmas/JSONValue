import Foundation

// MARK: - JSONable

public protocol JSONDecodable {
    associatedtype ConversionType = Self
    static func fromJSON(_ x: JSONValue) -> ConversionType?
}

public protocol JSONEncodable {
    associatedtype ConversionType
    static func toJSON(_ x: ConversionType) -> JSONValue
}

public protocol JSONable: JSONDecodable, JSONEncodable { }

extension Dictionary: JSONable {
    public typealias ConversionType = Dictionary<String, Value>
    public static func fromJSON(_ x: JSONValue) -> Dictionary.ConversionType? {
        switch x {
        case .object:
            return x.values() as? Dictionary<String, Value>
        default:
            return nil
        }
    }
    
    public static func toJSON(_ x: Dictionary.ConversionType) -> JSONValue {
        do {
            return try JSONValue(dict: x)
        } catch {
            return JSONValue.null
        }
    }
}

extension Array: JSONable {
    public static func fromJSON(_ x: JSONValue) -> Array? {
        return x.values() as? Array
    }
    
    public static func toJSON(_ x: Array) -> JSONValue {
        do {
            return try JSONValue(array: x)
        } catch {
            return JSONValue.null
        }
    }
}

extension Bool: JSONable {
    public static func fromJSON(_ x: JSONValue) -> Bool? {
        switch x {
        case let .bool(n):
            return n
        case .number(.int(0)):
            return false
        case .number(.int(1)):
            return true
        default:
            return nil
        }
    }
    
    public static func toJSON(_ xs: Bool) -> JSONValue {
        return JSONValue.bool(xs)
    }
}

extension Int: JSONable {
    public static func fromJSON(_ x: JSONValue) -> Int? {
        switch x {
        case let .number(n):
            switch n {
            case .int(let i): return Int(exactly: i)
            case .fraction(let f): return Int(exactly: f)
            }
        case let .string(s):
            return Int(s)
        default:
            return nil
        }
    }
    
    public static func toJSON(_ xs: Int) -> JSONValue {
        return JSONValue.number(.int(Int64(xs)))
    }
}

extension Double: JSONable {
    public static func fromJSON(_ x: JSONValue) -> Double? {
        switch x {
        case let .number(n):
            return n.doubleValue
        case let .string(s):
            return Double(s)
        default:
            return nil
        }
    }
    
    public static func toJSON(_ xs: Double) -> JSONValue {
        return JSONValue.number(.fraction(xs))
    }
}

extension NSNumber: JSONable {
    public class func fromJSON(_ x: JSONValue) -> NSNumber? {
        switch x {
        case let .number(n):
            switch n {
            case .int(let i): return NSNumber(value: i)
            case .fraction(let f): return NSNumber(value: f)
            }
        case let .bool(b):
            return NSNumber(value: b)
        case let .string(s):
            guard let n = Double(s) else {
                return nil
            }
            return NSNumber(value: n)
        default:
            return nil
        }
    }
    
    public class func toJSON(_ x: NSNumber) -> JSONValue {
        if x.isBool {
            return JSONValue.bool(x.boolValue)
        }
        else {
            return JSONValue.number(.fraction(x.doubleValue))
        }
    }
}

extension String: JSONable {
    public static func fromJSON(_ x: JSONValue) -> String? {
        switch x {
        case let .string(n):
            return n
        default:
            return nil
        }
    }
    
    public static func toJSON(_ x: String) -> JSONValue {
        return JSONValue.string(x)
    }
}

extension Date: JSONable {
    public static func fromJSON(_ x: JSONValue) -> Date? {
        switch x {
        case let .string(string):
            return Date(isoString: string)
        default:
            return nil
        }
    }
    
    public static func toJSON(_ x: Date) -> JSONValue {
        return .string(x.isoString)
    }
}

extension NSDate: JSONable {
    public static func fromJSON(_ x: JSONValue) -> NSDate? {
        return Date.fromJSON(x) as NSDate?
    }
    
    public static func toJSON(_ x: NSDate) -> JSONValue {
        return Date.toJSON(x as Date)
    }
}

extension NSNull: JSONable {
    public class func fromJSON(_ x: JSONValue) -> NSNull? {
        switch x {
        case .null:
            return NSNull()
        default:
            return nil
        }
    }
    
    public class func toJSON(_ xs: NSNull) -> JSONValue {
        return JSONValue.null
    }
}
