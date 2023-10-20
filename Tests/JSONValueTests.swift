import JSONValueRX
import XCTest

class JSONValueTests: XCTestCase {
    // MARK: - Subscripting
    
    func testSubscriptingWithDotsUsesComponentsForTraversal() {
        let dict = ["derp": ["blerp": ["a", "b"]]]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertEqual(jObj["derp.blerp"], try! JSONValue(array: ["a", "b"]))
    }
    
    func testSubscriptingWithDotsUsesWholeStringIfComponentsFail() {
        let dict = ["derp.blerp": ["a", "b"]]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertEqual(jObj["derp.blerp"], try! JSONValue(array: ["a", "b"]))
    }
    
    func testSubscriptingReturnsNilIfAttributeIsNonExistent() {
        let dict = ["derp": ["blerp": ["a", "b"]]]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertNil(jObj["herp"])
    }
    
    func testArraySubscripting() {
        let arr = [1 as Int, "derp", [3, 5.0]] as [Any]
        var jObj = try! JSONValue(array: arr)
        
        XCTAssertEqual(jObj[0], JSONValue.number(.int(1)))
        XCTAssertEqual(jObj[1], JSONValue.string("derp"))
        XCTAssertEqual(jObj[2]?[1], JSONValue.number(.fraction(5)))
        
        jObj[2] = JSONValue.string("yo")
        
        XCTAssertEqual(jObj[0], JSONValue.number(.int(1)))
        XCTAssertEqual(jObj[1], JSONValue.string("derp"))
        XCTAssertEqual(jObj[2], JSONValue.string("yo"))
        
        jObj[0] = nil
        
        XCTAssertEqual(jObj[0], JSONValue.string("derp"))
        XCTAssertEqual(jObj[1], JSONValue.string("yo"))
    }
    
    func testEarlyNullReturnsNullWhenSubscriptingKeyPath() {
        let dict = ["derp": NSNull()]
        let jObj = try! JSONValue(dict: dict)
        
        XCTAssertEqual(jObj["derp.blerp"], JSONValue.null)
    }
    
    // MARK: - Hashable
    
    func testFalseAndTrueHashesAreNotEqual() {
        let jFalse = JSONValue.bool(false)
        let jTrue = JSONValue.bool(true)
        XCTAssertNotEqual(jFalse.hashValue, jTrue.hashValue)
    }
    
    func testHashesAreConsistent() {
        let jNull = JSONValue.null
        XCTAssertEqual(jNull.hashValue, jNull.hashValue)
        
        let jBool = JSONValue.bool(false)
        XCTAssertEqual(jBool.hashValue, jBool.hashValue)
        
        let jNum = JSONValue.number(.fraction(3.0))
        XCTAssertEqual(jNum.hashValue, jNum.hashValue)
        
        let jString = JSONValue.string("some json")
        XCTAssertEqual(jString.hashValue, jString.hashValue)
        
        let jDict = JSONValue.object([
            "a string": .number(.fraction(6.0)),
            "another": .null,
        ])
        XCTAssertEqual(jDict.hashValue, jDict.hashValue)
        
        let jArray = JSONValue.array([.number(.fraction(6.0)), .string("yo"), jDict])
        XCTAssertEqual(jArray.hashValue, jArray.hashValue)
    }
    
    func testUniqueHashesForKeyValueReorderingOnJSONObject() {
        let string1 = "blah"
        let string2 = "derp"
        
        let obj1 = JSONValue.object([string1: .string(string2)])
        let obj2 = JSONValue.object([string2: .string(string1)])
        
        XCTAssertNotEqual(obj1.hashValue, obj2.hashValue)
    }
    
    func testUniqueHashesForJSONArrayReordering() {
        let string1 = "blah"
        let string2 = "derp"
        
        let arr1 = JSONValue.array([.string(string1), .string(string2)])
        let arr2 = JSONValue.array([.string(string2), .string(string1)])
        
        XCTAssertNotEqual(arr1.hashValue, arr2.hashValue)
    }
    
    func test0NumberFalseAndNullHashesAreUnique() {
        let jNull = JSONValue.null
        let jBool = JSONValue.bool(false)
        let jNum = JSONValue.number(.fraction(0.0))
        let jString = JSONValue.string("\0")
        
        XCTAssertNotEqual(jNull.hashValue, jBool.hashValue)
        XCTAssertNotEqual(jNull.hashValue, jNum.hashValue)
        XCTAssertNotEqual(jNull.hashValue, jString.hashValue)
        
        XCTAssertNotEqual(jBool.hashValue, jNum.hashValue)
        XCTAssertNotEqual(jBool.hashValue, jString.hashValue)
        
        XCTAssertNotEqual(jNum.hashValue, jString.hashValue)
    }
    
    // MARK: - Codable
    
    func testCodable() {
        guard #available(OSX 10.13, iOS 11.0, *) else {
            XCTFail(".sortedKeys only available in MacOS 10.13+, iOS 11.0+")
            return
        }
        
        let jsonString = """
        [
          {
            "_id": "5d140a3fb5bbd5eaa41b512e",
            "guid": "9b0f3717-2f21-4a81-8902-92d2278a92f0",
            "isActive": false,
            "age": 30,
            "shares": 5.51,
            "name": {
              "first": "Rosales",
              "last": "Mcintosh"
            },
            "company": null,
            "latitude": "-58.182284",
            "longitude": "-159.420718",
            "tags": [
              "aute",
              "aute",
            ],
            "range": [
              0,
              1,
              2,
              3,
            ],
            "friends": [
              {
                "id": 0,
                "name": "Gail Hoover"
              },
              {
                "id": 1,
                "name": "Luisa Galloway"
              },
              {
                "id": 2,
                "name": "Turner Strickland"
              }
            ],
            "greeting": "Hello, Rosales! You have 7 unread messages.",
            "favoriteFruit": "apple"
          }
        ]
        """
        let jsonValue = try! JSONDecoder().decode(JSONValue.self, from: jsonString.data(using: .utf8)!)
        XCTAssertEqual(jsonValue, .array([
            .object([
                "_id": .string("5d140a3fb5bbd5eaa41b512e"),
                "guid": .string("9b0f3717-2f21-4a81-8902-92d2278a92f0"),
                "isActive": .bool(false),
                "age": .number(.int(30)),
                "shares": .number(.fraction(5.51)),
                "name": .object([
                    "first": .string("Rosales"),
                    "last": .string("Mcintosh"),
                ]),
                "company": JSONValue.null,
                "latitude": .string("-58.182284"),
                "longitude": .string("-159.420718"),
                "tags": .array([
                    .string("aute"),
                    .string("aute"),
                ]),
                "range": .array([
                    .number(.int(0)),
                    .number(.int(1)),
                    .number(.int(2)),
                    .number(.int(3)),
                ]),
                "friends": .array([
                    .object([
                        "id": .number(.int(0)),
                        "name": .string("Gail Hoover"),
                    ]),
                    .object([
                        "id": .number(.int(1)),
                        "name": .string("Luisa Galloway"),
                    ]),
                    .object([
                        "id": .number(.int(2)),
                        "name": .string("Turner Strickland"),
                    ]),
                ]),
                "greeting": .string("Hello, Rosales! You have 7 unread messages."),
                "favoriteFruit": .string("apple"),
            ]),
        ]))
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let jsonData = try! encoder.encode(jsonValue)
        let jsonEncodedString = String(data: jsonData, encoding: .utf8)!
        // To compare against our original string we must first format it correctly.
        // Pass it through old JSON encode/decode to do so.
        let data = jsonString.data(using: .utf8)
        let jsonObj = try! JSONSerialization.jsonObject(with: data!, options: [])
        let jsonFormattedData = try! JSONSerialization.data(withJSONObject: jsonObj, options: [.sortedKeys])
        let jsonFormattedString = String(data: jsonFormattedData, encoding: .utf8)!
        
        XCTAssertEqual(jsonEncodedString, jsonFormattedString)
    }
    
    func testDecodeToStruct() {
        let jsonValue = JSONValue.array([
            .object([
                "_id": .string("5d140a3fb5bbd5eaa41b512e"),
                "guid": .string("9b0f3717-2f21-4a81-8902-92d2278a92f0"),
                "isActive": .bool(false),
                "age": .number(.int(30)),
                "name": .object([
                    "first": .string("Rosales"),
                    "last": .string("Mcintosh"),
                ]),
                "company": JSONValue.null,
                "latitude": .string("-58.182284"),
                "longitude": .string("-159.420718"),
                "tags": .array([
                    .string("aute"),
                    .string("aute"),
                ]),
            ]),
        ])
        
        struct Output: Decodable, Equatable {
            let _id: String
            let guid: String
            let isActive: Bool
            let age: Int
            let name: [String: String]
            let company: String?
            let latitude: String
            let longitude: String
            let tags: [String]
        }
        
        let output: [Output] = try! jsonValue.decode()
        XCTAssertEqual(
            output,
            [
                Output(_id: "5d140a3fb5bbd5eaa41b512e",
                       guid: "9b0f3717-2f21-4a81-8902-92d2278a92f0",
                       isActive: false,
                       age: 30,
                       name: [
                           "first": "Rosales",
                           "last": "Mcintosh",
                       ],
                       company: nil,
                       latitude: "-58.182284",
                       longitude: "-159.420718",
                       tags: [
                           "aute",
                           "aute",
                       ]),
            ]
        )
    }
    
    func testMissingDataFailsDecoding() {
        let jsonValue = JSONValue.object(["something": .string("unnecessary")])
        
        struct Output: Decodable, Encodable {
            let somethingNecessary: Bool
        }
        XCTAssertThrowsError(try jsonValue.decode() as Output)
    }
    
    // MARK: - Arrays
    
    func testArrayToFromJSONConvertsProperly() {
        let array = [987 as Int, 65.4192387490172384970123894] as [Any]
        let json = try! JSONValue(object: array)
        XCTAssertEqual(json[0], JSONValue.number(.int(987)))
        XCTAssertEqual(json[1], JSONValue.number(.fraction(65.4192387490172384970123894)))
        let from = Array<Any>.fromJSON(json)!
        print(from)
        XCTAssertEqual(from[0] as! Int, array[0] as! Int)
        XCTAssertEqual(from[1] as! Double, array[1] as! Double)
    }
    
    func testArrayOfIntJSONablesProperly() {
        let array: [Int] = [987, 45, 1235]
        let json = try! JSONValue(object: array)
        let result = Array<Int>.fromJSON(json)
        XCTAssertEqual(array, result)
    }
    
    func testArrayOfInt8JSONablesProperly() {
        let array: [Int] = [987, 45, 1235]
        let json = try! JSONValue(object: array)
        let result = Array<Int8>.fromJSON(json)
        XCTAssertNil(result)
    }
    
    func testArrayOfIntAndIntegerDoubleLikeIntsJSONablesProperly() {
        let array = [987, 45, 1235.0]
        let json = try! JSONValue(object: array)
        let result = Array<Int64>.fromJSON(json)
        XCTAssertEqual([987, 45, 1235], result)
    }
    
    func testArrayOfIntAndFractionalDoubleJSONablesProperly() {
        let array = [987, 45, 1235.1]
        let json = try! JSONValue(object: array)
        let result = Array<Int64>.fromJSON(json)
        XCTAssertNil(result)
    }
    
    // MARK: - Int
    
    func testJsonStringCoercesToInt() {
        let json = JSONValue.string("1")
        XCTAssertEqual(Int.fromJSON(json), 1)
        let garbage = JSONValue.string("a")
        XCTAssertNil(Int.fromJSON(garbage))
    }
    
    func testPrintingJsonNumberAsInt() {
        XCTAssertEqual("\(JSONNumber.int(1))", "1")
    }
    
    // MARK: - Double
    
    func testJsonStringCoercesToDouble() {
        let json = JSONValue.string("1")
        XCTAssertEqual(Double.fromJSON(json), 1.0)
        let json2 = JSONValue.string("1.4")
        XCTAssertEqual(Double.fromJSON(json2), 1.4)
        let garbage = JSONValue.string("a")
        XCTAssertNil(Double.fromJSON(garbage))
    }
    
    func testPrintingJsonNumberAsFraction() {
        XCTAssertEqual("\(JSONNumber.fraction(1.0))", "1.0")
    }
    
    // MARK: - NSNumber
    
    func testJsonStringCoercesToNSNumber() {
        let json = JSONValue.string("1.6")
        XCTAssertEqual(NSNumber.fromJSON(json), 1.6)
        let garbage = JSONValue.string("a")
        XCTAssertNil(Double.fromJSON(garbage))
    }
    
    func testJsonBoolCoercesToNSNumber() {
        let json = JSONValue.bool(true)
        XCTAssertEqual(NSNumber.fromJSON(json), true)
    }
    
    func testJsonBoolCoercesFromNSNumber() {
        let n: NSNumber = true
        XCTAssertEqual(NSNumber.toJSON(n), JSONValue.bool(true))
    }
    
    func testJsonNumberCoercesFromNSNumber() {
        let n: NSNumber = Double(1.2) as NSNumber
        XCTAssertEqual(NSNumber.toJSON(n), JSONValue.number(.fraction(1.2)))
    }
    
    // MARK: - NSDate
    
    func testJsonStringToNSDate() {
        let val = "2017-02-01T05:33:40Z"
        let json = JSONValue.string(val)
        let result = Date(isoString: val)! as NSDate
        XCTAssertEqual(NSDate.fromJSON(json), result)
        
        let valMilli = "2017-02-01T05:33:40.111Z"
        let jsonMilli = JSONValue.string(valMilli)
        let resultMilli = Date(isoString: valMilli)! as NSDate
        XCTAssertEqual(NSDate.fromJSON(jsonMilli), resultMilli)
        
        let garbage = JSONValue.string("a")
        XCTAssertNil(Double.fromJSON(garbage))
    }
    
    // MARK: - String encoding
    
    func testsEncodeAsString() {
        let dict = ["derp": ["blerp": ["a", "b"]]]
        let jObj = try! JSONValue(dict: dict)
        let jString = try! jObj.encodeAsString()
        XCTAssertEqual(jString, "{\"derp\":{\"blerp\":[\"a\",\"b\"]}}")
        
        let quote = "\""
        XCTAssertEqual(try! quote.jsonEncodedString(), "\"\\\"\"")
        
        let slash = "/"
        XCTAssertEqual(try! slash.jsonEncodedString(), "\"\\/\"")
        
        let newline = "\n"
        XCTAssertEqual(try! newline.jsonEncodedString(), "\"\\n\"")
        
        let returnCarriage = "\r"
        XCTAssertEqual(try! returnCarriage.jsonEncodedString(), "\"\\r\"")
        
        let tab = "\t"
        XCTAssertEqual(try! tab.jsonEncodedString(), "\"\\t\"")
        
        let thumbUp = "\u{1f44d}"
        XCTAssertEqual(try! thumbUp.jsonEncodedString(), "\"👍\"")
        
        let complex = ["1\\\r": ["[derp\n]👍"]]
        let json = try! JSONValue(dict: complex)
        let string = try! json.encodeAsString()
        XCTAssertEqual(string, "{\"1\\\\\\r\":[\"[derp\\n]👍\"]}")
    }
}

class UtilitiesTests: XCTestCase {
    func testIsBool() {
        XCTAssertTrue((true as NSNumber).isBool)
        XCTAssertTrue((false as NSNumber).isBool)
        XCTAssertFalse((1 as NSNumber).isBool)
        XCTAssertFalse((1.0 as NSNumber).isBool)
        XCTAssertFalse((0 as NSNumber).isBool)
        XCTAssertFalse((0.0 as NSNumber).isBool)
    }
    
    func testIsReal() {
        XCTAssertTrue((1.0 as NSNumber).isReal)
        XCTAssertTrue((1.1 as NSNumber).isReal)
        XCTAssertFalse((1 as NSNumber).isReal)
    }
    
    func testAsJsonNumber() {
        XCTAssertEqual(NSNumber(1).asJSONNumber, JSONNumber.int(1))
        XCTAssertEqual(NSNumber(1.0).asJSONNumber, JSONNumber.fraction(1.0))
    }
}
