import Delis

final class LibraryService: Autowired {
    let testService: TestService
    let books: [Book]

    required init(_ testService: TestService, _ books: [Book]) {
        self.testService = testService
        self.books = books
    }
}
