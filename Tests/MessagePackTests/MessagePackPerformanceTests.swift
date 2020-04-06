import XCTest
import MessagePack

class MessagePackPerformanceTests: XCTestCase {
    let count = 1000

    func testMessagePackPerformance() {
        let encoder = MessagePackEncoder()
        let decoder = MessagePackDecoder()

        let values = [Airport](repeating: .example, count: count)
        
        self.measure {
            let encoded = try! encoder.encode(values)
            let decoded = try! decoder.decode([Airport].self, from: encoded)
            XCTAssertEqual(decoded.count, count)
        }
    }

    func testJSONPerformance() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let values = [Airport](repeating: .example, count: count)

        self.measure {
            let encoded = try! encoder.encode(values)
            let decoded = try! decoder.decode([Airport].self, from: encoded)
            XCTAssertEqual(decoded.count, count)
        }
    }
}
