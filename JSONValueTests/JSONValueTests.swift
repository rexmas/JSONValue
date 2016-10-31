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
        
        XCTAssertEqual(jObj[0], JSONValue.jsonNumber(1))
        XCTAssertEqual(jObj[1], JSONValue.jsonString("derp"))
        
        jObj[2] = JSONValue.jsonString("yo")
        
        XCTAssertEqual(jObj[0], JSONValue.jsonNumber(1))
        XCTAssertEqual(jObj[1], JSONValue.jsonString("derp"))
        XCTAssertEqual(jObj[2], JSONValue.jsonString("yo"))
        
        jObj[0] = nil
        
        XCTAssertEqual(jObj[0], JSONValue.jsonString("derp"))
        XCTAssertEqual(jObj[1], JSONValue.jsonString("yo"))
    }
    
    // MARK: - Hashable
    
    func testFalseAndTrueHashesAreNotEqual() {
        let jFalse = JSONValue.jsonBool(false)
        let jTrue = JSONValue.jsonBool(true)
        XCTAssertNotEqual(jFalse.hashValue, jTrue.hashValue)
    }
    
    func testHashesAreDeterministic() {
        
        let jNull = JSONValue.jsonNull()
        XCTAssertEqual(jNull.hashValue, jNull.hashValue)
        
        let jBool = JSONValue.jsonBool(false)
        XCTAssertEqual(jBool.hashValue, jBool.hashValue)
        
        let jNum = JSONValue.jsonNumber(3.0)
        XCTAssertEqual(jNum.hashValue, jNum.hashValue)
        
        let jString = JSONValue.jsonString("some json")
        XCTAssertEqual(jString.hashValue, jString.hashValue)
        
        let jDict = JSONValue.jsonObject([
            "a string" : .jsonNumber(6.0),
            "another" : .jsonNull()
            ])
        XCTAssertEqual(jDict.hashValue, jDict.hashValue)
        
        let jArray = JSONValue.jsonArray([ .jsonNumber(6.0), .jsonString("yo"), jDict ])
        XCTAssertEqual(jArray.hashValue, jArray.hashValue)
    }
    
    func testUniqueHashesForKeyValueReorderingOnJSONObject() {
        let string1 = "blah"
        let string2 = "derp"
        
        let obj1 = JSONValue.jsonObject([ string1 : .jsonString(string2) ])
        let obj2 = JSONValue.jsonObject([ string2 : .jsonString(string1) ])
        
        XCTAssertNotEqual(obj1.hashValue, obj2.hashValue)
    }
    
    func testUniqueHashesForJSONArrayReordering() {
        let string1 = "blah"
        let string2 = "derp"
        
        let arr1 = JSONValue.jsonArray([ .jsonString(string1), .jsonString(string2) ])
        let arr2 = JSONValue.jsonArray([ .jsonString(string2), .jsonString(string1) ])
        
        XCTAssertNotEqual(arr1.hashValue, arr2.hashValue)
    }
    
    func test0NumberFalseAndNullHashesAreUnique() {
        let jNull = JSONValue.jsonNull()
        let jBool = JSONValue.jsonBool(false)
        let jNum = JSONValue.jsonNumber(0.0)
        let jString = JSONValue.jsonString("\0")
        
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
        XCTAssertEqual(json[0], JSONValue.jsonNumber(987.0))
        XCTAssertEqual(json[1], JSONValue.jsonNumber(65.4))
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
