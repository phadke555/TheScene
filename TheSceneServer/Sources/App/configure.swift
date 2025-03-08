import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    if let databaseURL = Environment.get("DATABASE_URL") {
        var tlsConfig: TLSConfiguration = .makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        let nioSSLContext = try NIOSSLContext(configuration: tlsConfig)

        var postgresConfig = try SQLPostgresConfiguration(url: databaseURL)
        postgresConfig.coreConfiguration.tls = .require(nioSSLContext)

        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } else {
        try app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "postgres",
            password: Environment.get("DATABASE_PASSWORD") ?? nil,
            database: Environment.get("DATABASE_NAME") ?? "thescene",
            tls: .prefer(.init(configuration: .clientDefault)))
        ), as: .psql)
    }
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    decoder.dateDecodingStrategy = .deferredToDate
    encoder.dateEncodingStrategy = .deferredToDate
    ContentConfiguration.global.use(decoder: decoder, for: .json)
    ContentConfiguration.global.use(encoder: encoder, for: .json)
    app.migrations.add(Initialize())

    // register routes
    try routes(app)
}

extension Request {
    func getUser() async throws -> User {
        guard let userId: String = self.query["userId"] else {
            throw Abort(.unauthorized)
        }
        var user = try? await User.query(on: self.db)
            .filter(\.$uuid == userId)
            .first()
        if user == nil {
            user = User(uuid: userId)
            try await user?.save(on: self.db)
        }
        guard let user = user else {
            throw Abort(.internalServerError)
        }
        return user
    }
}
