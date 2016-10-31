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
}
