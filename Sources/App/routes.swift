import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, Zaheer!"
    }
    

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.get("popular" , use: todoController.getBooks)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


struct PopularBook: Codable, Content {
    var isbns: String
}

struct PopularBooks: Codable, Content {
    var books: [PopularBook]
}
