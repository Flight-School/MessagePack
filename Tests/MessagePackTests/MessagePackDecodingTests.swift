@testable import MessagePack
import XCTest

class MessagePackDecodingTests: XCTestCase {
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        decoder = MessagePackDecoder()
    }

    func assertTypeMismatch<T>(_ expression: @autoclosure () throws -> T,
                               _ message: @autoclosure () -> String = "",
                               file: StaticString = #file,
                               line: UInt = #line) -> Any.Type?
    {
        var error: Error?
        XCTAssertThrowsError(try expression(),
                             message(),
                             file: file,
                             line: line) {
            error = $0
        }
        guard case .typeMismatch(let type, _) = error as? DecodingError else {
            XCTFail(file: file, line: line)
            return nil
        }
        return type
    }
    
    func testDecodeNil() {
        let data = Data([0xc0])
        let value = try! decoder.decode(Int?.self, from: data)
        XCTAssertNil(value)
    }
    
    func testDecodeFalse() {
        let data = Data([0xc2])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, false)
    }
    
    func testDecodeTrue() {
        let data = Data([0xc3])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, true)
    }
    
    func testDecodeInt() {
        let data = Data([0x2a])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 42)
    }

    func testDecodeNegativeInt() {
        let data = Data([0xff])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, -1)
    }
    
    func testDecodeUInt() {
        let data = Data([0xcc, 0x80])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 128)
    }
    
    func testDecodeFloat() {
        let data = Data([0xca, 0x40, 0x48, 0xf5, 0xc3])
        let value = try! decoder.decode(Float.self, from: data)
        XCTAssertEqual(value, 3.14)
    }

    func testDecodeFloatToDouble() {
        let data = Data([0xca, 0x40, 0x48, 0xf5, 0xc3])
        let type = assertTypeMismatch(try decoder.decode(Double.self, from: data))
        XCTAssertTrue(type is Double.Type)
        decoder.nonMatchingFloatDecodingStrategy = .cast
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14, accuracy: 1e-6)
    }
    
    func testDecodeDouble() {
        let data = Data([0xcb, 0x40, 0x09, 0x21, 0xf9, 0xf0, 0x1b, 0x86, 0x6e])
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }

    func testDecodeDoubleToFloat() {
        let data = Data([0xcb, 0x40, 0x09, 0x21, 0xf9, 0xf0, 0x1b, 0x86, 0x6e])
        let type = assertTypeMismatch(try decoder.decode(Float.self, from: data))
        XCTAssertTrue(type is Float.Type)
        decoder.nonMatchingFloatDecodingStrategy = .cast
        let value = try! decoder.decode(Float.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }
    
    func testDecodeFixedArray() {
        let data = Data([0x93, 0x01, 0x02, 0x03])
        let value = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeVariableArray() {
        let data = Data([0xdc] + [0x00, 0x10] + Array(0x01...0x10))
        let value = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(value, Array(1...16))
    }

    func testDecodeFixedDictionary() {
        let data = Data([0x83, 0xa1, 0x62, 0x02, 0xa1, 0x61, 0x01, 0xa1, 0x63, 0x03])
        let value = try! decoder.decode([String: Int].self, from: data)
        XCTAssertEqual(value, ["a": 1, "b": 2, "c": 3])
    }
    
    func testDecodeData() {
        let data = Data([0xc4, 0x05, 0x68, 0x65, 0x6c, 0x6c, 0x6f])
        let value = try! decoder.decode(Data.self, from: data)
        XCTAssertEqual(value, "hello".data(using: .utf8))
    }
    
    func testDecodeDate() {
        let data = Data([0xd6, 0xff, 0x00, 0x00, 0x00, 0x01])
        let date = Date(timeIntervalSince1970: 1)
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeDistantPast() {
        let data = Data([0xc7, 0x0c, 0xff, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xf1, 0x88, 0x6b, 0x66, 0x00])
        let date = Date.distantPast
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeDistantFuture() {
        let data = Data([0xc7, 0x0c, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0xec, 0x31, 0x88, 0x00])
        let date = Date.distantFuture
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeArrayWithDate() {
        let data = Data([0x91, 0xd6, 0xff, 0x00, 0x00, 0x00, 0x01])
        let date = Date(timeIntervalSince1970: 1)
        let value = try! decoder.decode([Date].self, from: data)
        XCTAssertEqual(value, [date])
    }
    
    func testDecodeDictionaryWithDate() {
        let data = Data([0x81, 0xa1, 0x31, 0xd6, 0xff, 0x00, 0x00, 0x00, 0x01])
        let date = Date(timeIntervalSince1970: 1)
        let value = try! decoder.decode([String: Date].self, from: data)
        XCTAssertEqual(value, ["1": date])
    }

    static var allTests = [
        ("testDecodeNil", testDecodeNil),
        ("testDecodeFalse", testDecodeFalse),
        ("testDecodeTrue", testDecodeTrue),
        ("testDecodeInt", testDecodeInt),
        ("testDecodeUInt", testDecodeUInt),
        ("testDecodeFloat", testDecodeFloat),
        ("testDecodeFloatToDouble", testDecodeFloatToDouble),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeDoubleToFloat", testDecodeDoubleToFloat),
        ("testDecodeFixedArray", testDecodeFixedArray),
        ("testDecodeFixedDictionary", testDecodeFixedDictionary),
        ("testDecodeData", testDecodeData),
        ("testDecodeDistantPast", testDecodeDistantPast),
        ("testDecodeDistantFuture", testDecodeDistantFuture),
        ("testDecodeArrayWithDate", testDecodeArrayWithDate),
        ("testDecodeDictionaryWithDate", testDecodeDictionaryWithDate)
    ]
}
