import XCTest
@testable import MessagePack

class MessagePackDecodingTests: XCTestCase {
    var decoder: MessagePackDecoder!
    
    override func setUp() {
        self.decoder = MessagePackDecoder()
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
    
    func testDecodeIntFromUInt() {
        let data = Data(bytes: [0xCC, 0x80])
        let value = try! decoder.decode(Int.self, from: data)
        XCTAssertEqual(value, 128)
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

    static var allTests = [
        ("testDecodeFalse", testDecodeFalse),
        ("testDecodeTrue", testDecodeTrue),
        ("testDecodeInt", testDecodeInt),
        ("testDecodeDouble", testDecodeDouble),
        ("testDecodeArray", testDecodeArray)
//        ("testDecodeDictionary", testDecodeDictionary)
    ]
}
