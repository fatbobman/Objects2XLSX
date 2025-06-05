@testable import Objects2XLSX
import Testing

@Test func example() async throws {
    let column = Column(name: "name", keyPath: \Student.name, nilHandling: .defaultValue("abc"))
}
