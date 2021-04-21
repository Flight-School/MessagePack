import XCTest
@testable import MessagePack

class MessagePackDecodingTests: XCTestCase {
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.decoder = MessagePackDecoder()
    }

    func assertTypeMismatch<T>(_ expression: @autoclosure () throws -> T,
                               _ message: @autoclosure () -> String = "",
                               file: StaticString = #filePath,
                               line: UInt = #line) -> Any.Type? {
        var error: Error?
        XCTAssertThrowsError(expression, message,
                             file: file, line: line) {
            error = $0
        }
        guard case .typeMismatch(let type, _) = error as? DecodingError else {
            XCTFail(file: file, line: line)
            return nil
        }
        return type
    }
    
    func testDecodeNil() {
        let data = Data(bytes: [0xC0])
        let value = try! decoder.decode(Int?.self, from: data)
        XCTAssertNil(value)
    }
    
    func testDecodeFalse() {
        let data = Data(bytes: [0xc2])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, false)
    }
    
    func testDecodeTrue() {
        let data = Data(bytes: [0xc3])
        let value = try! decoder.decode(Bool.self, from: data)
        XCTAssertEqual(value, true)
    }
    
    func testDecodeInt() {
        let data = Data(bytes: [0x2A])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 42)
    }

    func testDecodeNegativeInt() {
        let data = Data(bytes: [0xFF])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, -1)
    }
    
    func testDecodeUInt() {
        let data = Data(bytes: [0xCC, 0x80])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 128)
    }
    
    func testDecodeFloat() {
        let data = Data(bytes: [0xCA, 0x40, 0x48, 0xF5, 0xC3])
        let value = try! decoder.decode(Float.self, from: data)
        XCTAssertEqual(value, 3.14)
    }

    func testDecodeFloatToDouble() {
        let data = Data(bytes: [0xCA, 0x40, 0x48, 0xF5, 0xC3])
        let type = assertTypeMismatch(try decoder.decode(Double.self, from: data))
        XCTAssertTrue(type is Double.Type)
        decoder.nonMatchingFloatDecodingStrategy = .cast
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14, accuracy: 1e-6)
    }
    
    func testDecodeDouble() {
        let data = Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E])
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }

    func testDecodeDoubleToFloat() {
        let data = Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E])
        let type = assertTypeMismatch(try decoder.decode(Float.self, from: data))
        XCTAssertTrue(type is Float.Type)
        decoder.nonMatchingFloatDecodingStrategy = .cast
        let value = try! decoder.decode(Float.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }
    
    func testDecodeFixedArray() {
        let data = Data(bytes: [0x93, 0x01, 0x02, 0x03])
        let value = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeVariableArray() {
        let data = Data(bytes: [0xdc] + [0x00, 0x10] + Array(0x01...0x10))
        let value = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(value, Array(1...16))
    }

    func testDecodeFixedDictionary() {
        let data = Data(bytes: [0x83, 0xA1, 0x62, 0x02, 0xA1, 0x61, 0x01, 0xA1, 0x63, 0x03])
        let value = try! decoder.decode([String: Int].self, from: data)
        XCTAssertEqual(value, ["a": 1, "b": 2, "c": 3])
    }
    
    func testDecodeData() {
        let data = Data(bytes: [0xC4, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F])
        let value = try! decoder.decode(Data.self, from: data)
        XCTAssertEqual(value, "hello".data(using: .utf8))
    }
    
    func testDecodeDate() {
        let data = Data(bytes: [0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
        let date = Date(timeIntervalSince1970: 1)
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeDistantPast() {
        let data = Data(bytes: [0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xF1, 0x88, 0x6B, 0x66, 0x00])
        let date = Date.distantPast
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeDistantFuture() {
        let data = Data(bytes: [0xC7, 0x0C, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0xEC, 0x31, 0x88, 0x00])
        let date = Date.distantFuture
        let value = try! decoder.decode(Date.self, from: data)
        XCTAssertEqual(value, date)
    }
    
    func testDecodeArrayWithDate() {
        let data = Data(bytes: [0x91, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
        let date = Date(timeIntervalSince1970: 1)
        let value = try! decoder.decode([Date].self, from: data)
        XCTAssertEqual(value, [date])
    }
    
    func testDecodeDictionaryWithDate() {
        let data = Data(bytes: [0x81, 0xA1, 0x31, 0xD6, 0xFF, 0x00, 0x00, 0x00, 0x01])
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
        ("testDecodeFloatToDouble", testDecodeFloatToDouble),
        ("testDecodeFixedArray", testDecodeFixedArray),
        ("testDecodeFixedDictionary", testDecodeFixedDictionary),
        ("testDecodeData", testDecodeData),
        ("testDecodeDistantPast", testDecodeDistantPast),
        ("testDecodeDistantFuture", testDecodeDistantFuture),
        ("testDecodeArrayWithDate", testDecodeArrayWithDate),
        ("testDecodeDictionaryWithDate", testDecodeDictionaryWithDate)
    ]
}
