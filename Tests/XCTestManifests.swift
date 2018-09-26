import XCTest

extension JSONValueTests {
    static let __allTests = [
        ("test0NumberFalseAndNullHashesAreUnique", test0NumberFalseAndNullHashesAreUnique),
        ("testArrayOfInt8JSONablesProperly", testArrayOfInt8JSONablesProperly),
        ("testArrayOfIntJSONablesProperly", testArrayOfIntJSONablesProperly),
        ("testArraySubscripting", testArraySubscripting),
        ("testArrayToFromJSONConvertsProperly", testArrayToFromJSONConvertsProperly),
        ("testEarlyNullReturnsNullWhenSubscriptingKeyPath", testEarlyNullReturnsNullWhenSubscriptingKeyPath),
        ("testFalseAndTrueHashesAreNotEqual", testFalseAndTrueHashesAreNotEqual),
        ("testHashesAreConsistent", testHashesAreConsistent),
        ("testJsonBoolCoercesFromNSNumber", testJsonBoolCoercesFromNSNumber),
        ("testJsonBoolCoercesToNSNumber", testJsonBoolCoercesToNSNumber),
        ("testJsonNumberCoercesFromNSNumber", testJsonNumberCoercesFromNSNumber),
        ("testJsonStringCoercesToDouble", testJsonStringCoercesToDouble),
        ("testJsonStringCoercesToInt", testJsonStringCoercesToInt),
        ("testJsonStringCoercesToNSNumber", testJsonStringCoercesToNSNumber),
        ("testJsonStringToNSDate", testJsonStringToNSDate),
        ("testsEncodeAsString", testsEncodeAsString),
        ("testSubscriptingReturnsNilIfAttributeIsNonExistent", testSubscriptingReturnsNilIfAttributeIsNonExistent),
        ("testSubscriptingWithDotsUsesComponentsForTraversal", testSubscriptingWithDotsUsesComponentsForTraversal),
        ("testSubscriptingWithDotsUsesWholeStringIfComponentsFail", testSubscriptingWithDotsUsesWholeStringIfComponentsFail),
        ("testUniqueHashesForJSONArrayReordering", testUniqueHashesForJSONArrayReordering),
        ("testUniqueHashesForKeyValueReorderingOnJSONObject", testUniqueHashesForKeyValueReorderingOnJSONObject),
    ]
}

#if !(os(macOS) || os(iOS))
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(JSONValueTests.__allTests),
    ]
}
#endif
