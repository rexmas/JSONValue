import XCTest
import JSONValue

class JSONValueTests: XCTestCase {
    
    // MARK: - Subscripting
    
    func testSubscriptingWithDotsUsesComponentsForTraversal() {
        let dict = [ "derp" : [ "blerp" : [ "a", "b" ] ] ]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertEqual(jObj["derp.blerp"], try! JSONValue(array: ["a", "b"]))
    }
    
    func testSubscriptingWithDotsUsesWholeStringIfComponentsFail() {
        let dict = [ "derp.blerp" : [ "a", "b" ] ]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertEqual(jObj["derp.blerp"], try! JSONValue(array: ["a", "b"]))
    }
    
    func testSubscriptingReturnsNilIfAttributeIsNonExistent() {
        let dict = [ "derp" : [ "blerp" : [ "a", "b" ] ] ]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertNil(jObj["herp"])
    }
    
    func testArraySubscripting() {
        let arr = [ 1, "derp" ] as [Any]
        var jObj = try! JSONValue(array: arr)
        
        XCTAssertEqual(jObj[0], JSONValue.number(1))
        XCTAssertEqual(jObj[1], JSONValue.string("derp"))
        
        jObj[2] = JSONValue.string("yo")
        
        XCTAssertEqual(jObj[0], JSONValue.number(1))
        XCTAssertEqual(jObj[1], JSONValue.string("derp"))
        XCTAssertEqual(jObj[2], JSONValue.string("yo"))
        
        jObj[0] = nil
        
        XCTAssertEqual(jObj[0], JSONValue.string("derp"))
        XCTAssertEqual(jObj[1], JSONValue.string("yo"))
    }
    
    // MARK: - Hashable
    
    func testFalseAndTrueHashesAreNotEqual() {
        let jFalse = JSONValue.bool(false)
        let jTrue = JSONValue.bool(true)
        XCTAssertNotEqual(jFalse.hashValue, jTrue.hashValue)
    }
    
    func testHashesAreDeterministic() {
        
        let jNull = JSONValue.null()
        XCTAssertEqual(jNull.hashValue, jNull.hashValue)
        
        let jBool = JSONValue.bool(false)
        XCTAssertEqual(jBool.hashValue, jBool.hashValue)
        
        let jNum = JSONValue.number(3.0)
        XCTAssertEqual(jNum.hashValue, jNum.hashValue)
        
        let jString = JSONValue.string("some json")
        XCTAssertEqual(jString.hashValue, jString.hashValue)
        
        let jDict = JSONValue.object([
            "a string" : .number(6.0),
            "another" : .null()
            ])
        XCTAssertEqual(jDict.hashValue, jDict.hashValue)
        
        let jArray = JSONValue.array([ .number(6.0), .string("yo"), jDict ])
        XCTAssertEqual(jArray.hashValue, jArray.hashValue)
    }
    
    func testUniqueHashesForKeyValueReorderingOnJSONObject() {
        let string1 = "blah"
        let string2 = "derp"
        
        let obj1 = JSONValue.object([ string1 : .string(string2) ])
        let obj2 = JSONValue.object([ string2 : .string(string1) ])
        
        XCTAssertNotEqual(obj1.hashValue, obj2.hashValue)
    }
    
    func testUniqueHashesForJSONArrayReordering() {
        let string1 = "blah"
        let string2 = "derp"
        
        let arr1 = JSONValue.array([ .string(string1), .string(string2) ])
        let arr2 = JSONValue.array([ .string(string2), .string(string1) ])
        
        XCTAssertNotEqual(arr1.hashValue, arr2.hashValue)
    }
    
    func test0NumberFalseAndNullHashesAreUnique() {
        let jNull = JSONValue.null()
        let jBool = JSONValue.bool(false)
        let jNum = JSONValue.number(0.0)
        let jString = JSONValue.string("\0")
        
        XCTAssertNotEqual(jNull.hashValue, jBool.hashValue)
        XCTAssertNotEqual(jNull.hashValue, jNum.hashValue)
        XCTAssertNotEqual(jNull.hashValue, jString.hashValue)
        
        XCTAssertNotEqual(jBool.hashValue, jNum.hashValue)
        XCTAssertNotEqual(jBool.hashValue, jString.hashValue)
        
        XCTAssertNotEqual(jNum.hashValue, jString.hashValue)
    }
    
    // MARK: - Arrays
    
    func testArrayToFromJSONConvertsProperly() {
        let array = [ 987 as Int, 65.4 ] as [Any]
        let json = try! JSONValue(object: array)
        XCTAssertEqual(json[0], JSONValue.number(987.0))
        XCTAssertEqual(json[1], JSONValue.number(65.4))
        let from = Array<Any>.fromJSON(json)!
        print(from)
        XCTAssertEqual(from[0] as! Double, Double(array[0] as! Int))
        XCTAssertEqual(from[1] as! Double, array[1] as! Double)
    }
    
    func testArrayOfIntJSONablesProperly() {
        let array: [Int] = [987, 45, 1235]
        let json = try! JSONValue(object: array)
        let result = Array<Int>.fromJSON(json)!
        XCTAssertEqual(array, result)
    }
}
