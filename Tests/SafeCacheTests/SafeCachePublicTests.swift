import XCTest
import SafeCache

final class SafeCachePublicTests: XCTestCase {
    var sut = SafeCache<String, TestObject>()
    
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSafeCache_WhenAddingDataToCache_ShouldBeValidAction() async throws {
        let text = TestObject()
        let key: String = "test"

        await sut.insert(text, forKey: key)
        let optional = await sut.value(forKey: key)
        let testResult = try XCTUnwrap(optional)
        XCTAssertEqual(testResult.text, text.text)
    }
    
    func testSafeCache_WhenRemovingDataFromCache_ShouldBeValidAction() async throws {
        let key = "test"
        await sut.removeValue(forKey: key)
        let testResult = await sut.value(forKey: key)
        XCTAssertNil(testResult)
    }
    
    func testSafeCache_WhenRemovingAllDataFromCache_ShouldBeValidAction() async throws {
        let text = TestObject()
        let key: String = "test"

        await sut.insert(text, forKey: key)
        await sut.insert(text, forKey: "test2")
        await sut.insert(text, forKey: "test3")
        let optional = await sut.value(forKey: "test2")
        let testResult = try XCTUnwrap(optional)
        XCTAssertEqual(testResult.text, text.text)
        await sut.removeAll()
        let optional2 = await sut.value(forKey: "test2")
        XCTAssertNil(optional2)
    }
    
    
    func testSafeCache_WhenPersistingAndSavingDataOnDisk_ShouldBeAbleToRetrieve() async throws {
        let text = TestObject()
        let key: String = "test"

        await sut.insert(text, forKey: key)
        try await sut.saveToDisk(withName: "plop")
        await sut.removeAll()
        try await sut.loadFromDisk(withName: "plop")
        let optional = await sut.value(forKey: key)
        let testResult = try XCTUnwrap(optional)
        XCTAssertEqual(testResult.text, text.text)

    }
    
    func testSafeCache_WhenExpirationTimeIsPassedDue_ShouldRemoveElement() async throws {
        sut = SafeCache<String, TestObject>(entryLifetime: 0)
        let text = TestObject()
        let key: String = "test"
        await sut.insert(text, forKey: key)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let optional = await sut[key]
        XCTAssertNil(optional)
        
    }
    
    func testSafeCache_WhenExpirationTimeIsPassedDueOnPersistedData_ShouldRemoveElement() async throws {
        sut = SafeCache<String, TestObject>(entryLifetime: 0)
        let text = TestObject()
        let key: String = "test"

        await sut.insert(text, forKey: key)
        try await sut.saveToDisk(withName: "plop")
        await sut.removeAll()
        try await sut.loadFromDisk(withName: "plop")
        let optional = await sut.value(forKey: key)
        XCTAssertNil(optional)
    }
}

extension FileManager: @unchecked Sendable {}

struct TestObject: Codable {
    var text: String = "test"
}

