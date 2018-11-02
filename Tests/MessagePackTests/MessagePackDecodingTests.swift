import XCTest
@testable import MessagePack

class MessagePackDecodingTests: XCTestCase {
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.decoder = MessagePackDecoder()
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
    
    func testDecodeDouble() {
        let data = Data(bytes: [0xCB, 0x40, 0x09, 0x21, 0xF9, 0xF0, 0x1B, 0x86, 0x6E])
        let value = try! decoder.decode(Double.self, from: data)
        XCTAssertEqual(value, 3.14159)
    }
    
    func testDecodeArray() {
        let data = Data(bytes: [0x93, 0x01, 0x02, 0x03])
        let value = try! decoder.decode([Int].self, from: data)
        XCTAssertEqual(value, [1, 2, 3])
    }

    func testDecodeDictionary() {
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
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeArray", testDecodeArray),
        ("testDecodeDictionary", testDecodeDictionary),
        ("testDecodeData", testDecodeData),
        ("testDecodeDate", testDecodeDate)
    ]
}
