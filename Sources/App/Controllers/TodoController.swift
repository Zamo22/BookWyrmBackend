import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
    
    
    func getPopularBooks(req: Request) throws -> Future<PopularBooks> {
        let urlToSearch = "http://idreambooks.com/api/publications/recent_recos.json?key=64f959b1d802bf39f22b52e8114cace510662582&slug=bestsellers"
        let client = try req.make(Client.self)
        let ans =  client.get(urlToSearch).flatMap { exampleResponse in
            return try exampleResponse.content.decode([PopularBook].self)
        }
        
        return ans.flatMap { model in
            let all = PopularBooks(books: model)
            return Future.map(on: req) {
                return all }
        }
    }

    func getBooks(req: Request) throws -> Future<Isbns> {
        let popularBookList = try getPopularBooks(req: req)

        return popularBookList.map(to: Isbns.self) { list in
            let bookList = try PopularBooks(books: list.books)
            var isbnList: [String] = []
            for book in bookList.books {
                let singleBookIsbns = book.isbns
                let isbnListArr: [String] = singleBookIsbns.components(separatedBy: ",")
                isbnList.append(isbnListArr.first ?? "123")
            }
            let isbns = try Isbns(isbnArray: isbnList)
            return isbns
        }


    }
    
}

struct Isbns: Codable, Content {
    var isbnArray: [String]
}
