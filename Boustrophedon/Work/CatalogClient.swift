import Foundation

/// Role: Work. Typed search faults. Decode never crashes the crate.
enum CatalogFault: Error, Equatable, Sendable {
    case cancelled
    case transport
    case malformed
}

/// Role: Work. Injected hop so tests stay in process.
protocol CatalogCarrying: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct CatalogSession: CatalogCarrying {
    let session: URLSession

    init(session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = CatalogClient.timeout
        configuration.timeoutIntervalForResource = CatalogClient.timeout
        configuration.httpAdditionalHeaders = ["User-Agent": CatalogClient.userAgent]
        return URLSession(configuration: configuration)
    }()) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

struct SparqlEnvelopeDTO: Decodable, Sendable {
    var results: SparqlResultsDTO?

    enum CodingKeys: String, CodingKey {
        case results
    }
}

struct SparqlResultsDTO: Decodable, Sendable {
    var bindings: [SparqlBindingDTO]?

    enum CodingKeys: String, CodingKey {
        case bindings
    }
}

struct SparqlBindingDTO: Decodable, Sendable {
    var item: SparqlValueDTO?
    var itemLabel: SparqlValueDTO?
    var makerLabel: SparqlValueDTO?
    var title: SparqlValueDTO?
    var accession: SparqlValueDTO?
    var image: SparqlValueDTO?

    enum CodingKeys: String, CodingKey {
        case item
        case itemLabel
        case makerLabel
        case title
        case accession
        case image
    }

    var qid: String? { CatalogClient.qid(from: item?.value) }
}

struct SparqlValueDTO: Decodable, Sendable {
    var type: String?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
}

struct EntityDataDTO: Decodable, Sendable {
    var entities: [String: EntityDTO]?

    enum CodingKeys: String, CodingKey {
        case entities
    }
}

struct EntityDTO: Decodable, Sendable {
    var id: String?
    var labels: [String: EntityLabelDTO]?
    var claims: [String: [EntityClaimDTO]]?

    enum CodingKeys: String, CodingKey {
        case id
        case labels
        case claims
    }

    var englishLabel: String? {
        let trimmed = (labels?["en"]?.value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var commonsFilename: String? {
        claims?["P18"]?.compactMap(\.stringValue).first
    }

    var nativeTitle: String? {
        claims?["P1476"]?.compactMap(\.stringValue).first
    }

    var accession: String? {
        claims?["P217"]?.compactMap(\.stringValue).first
    }

    var makerQID: String? {
        claims?["P170"]?.compactMap(\.entityID).first
    }
}

struct EntityLabelDTO: Decodable, Sendable {
    var language: String?
    var value: String?

    enum CodingKeys: String, CodingKey {
        case language
        case value
    }
}

struct EntityClaimDTO: Decodable, Sendable {
    var mainsnak: EntitySnakDTO?

    enum CodingKeys: String, CodingKey {
        case mainsnak
    }

    var stringValue: String? { mainsnak?.datavalue?.flexible.string }
    var entityID: String? { mainsnak?.datavalue?.flexible.entity }
}

struct EntitySnakDTO: Decodable, Sendable {
    var datavalue: EntityDataValueDTO?

    enum CodingKeys: String, CodingKey {
        case datavalue
    }
}

struct EntityDataValueDTO: Decodable, Sendable {
    var flexible: EntityFlexibleValue

    init(from decoder: Decoder) throws {
        let box = try decoder.container(keyedBy: CodingKeys.self)
        let raw = try box.decode(FlexibleJSON.self, forKey: .value)
        self.flexible = raw.flexible
    }

    enum CodingKeys: String, CodingKey {
        case value
    }
}

enum FlexibleJSON: Decodable, Sendable {
    case text(String)
    case object([String: FlexibleJSON])
    case other

    init(from decoder: Decoder) throws {
        if let text = try? decoder.singleValueContainer().decode(String.self) {
            self = .text(text)
            return
        }
        if let object = try? decoder.container(keyedBy: DynamicKey.self) {
            var map: [String: FlexibleJSON] = [:]
            for key in object.allKeys {
                map[key.stringValue] = (try? object.decode(FlexibleJSON.self, forKey: key)) ?? .other
            }
            self = .object(map)
            return
        }
        self = .other
    }

    var flexible: EntityFlexibleValue {
        switch self {
        case .text(let text):
            return EntityFlexibleValue(string: text, entity: nil)
        case .object(let map):
            let id = map["id"].flatMap { if case .text(let t) = $0 { return t } else { return nil } }
            return EntityFlexibleValue(string: id, entity: id)
        case .other:
            return EntityFlexibleValue(string: nil, entity: nil)
        }
    }
}

struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }
}

struct EntityFlexibleValue: Sendable {
    var string: String?
    var entity: String?
}

/// Role: Work. Paginated SPARQL search plus EntityData hydrate. National Gallery only.
struct CatalogClient: Sendable {
    static let userAgent = "Boustrophedon/1.0 (iOS; +https://boustrophedon-furrow.pro)"
    static let timeout: TimeInterval = 15
    static let searchURL = URL(string: "https://query.wikidata.org/sparql")!
    static let collectionQID = "Q180788"

    let carrier: any CatalogCarrying
    let decoder: JSONDecoder

    init(carrier: any CatalogCarrying = CatalogSession()) {
        self.carrier = carrier
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
    }

    static func qid(from uri: String?) -> String? {
        guard let uri, let last = uri.split(separator: "/").last else { return nil }
        let token = String(last)
        return token.hasPrefix("Q") ? token : nil
    }

    static func thumbURL(filename: String) -> URL? {
        let trimmed = filename.replacingOccurrences(of: " ", with: "_")
        var allowed = CharacterSet.urlPathAllowed
        allowed.insert(charactersIn: ":/")
        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(encoded)?width=843")
    }

    func search(query: String, page: Int, pageSize: Int) async throws -> [Work] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }
        let offset = max(0, page - 1) * pageSize
        var parts = URLComponents(url: Self.searchURL, resolvingAgainstBaseURL: false)!
        parts.queryItems = [
            URLQueryItem(name: "query", value: sparql(needle: trimmed, limit: pageSize, offset: offset)),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = parts.url else { throw CatalogFault.malformed }
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/sparql-results+json", forHTTPHeaderField: "Accept")
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await carrier.data(for: request)
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch {
            throw CatalogFault.transport
        }
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CatalogFault.transport
        }
        let envelope: SparqlEnvelopeDTO
        do {
            envelope = try decoder.decode(SparqlEnvelopeDTO.self, from: data)
        } catch {
            throw CatalogFault.malformed
        }
        let bindings = envelope.results?.bindings ?? []
        var works: [Work] = []
        for binding in bindings {
            guard let id = binding.qid else { continue }
            let hydrated = try await hydrate(id: id)
            let imageName = filename(from: binding.image?.value) ?? hydrated?.imageFile ?? ""
            let maker = nonempty(binding.makerLabel?.value) ?? hydrated?.maker ?? ""
            let title = nonempty(binding.title?.value) ?? nonempty(binding.itemLabel?.value) ?? hydrated?.title ?? ""
            let identity = nonempty(binding.accession?.value) ?? hydrated?.identity ?? id
            let work = Work(
                id: id,
                identity: identity,
                maker: maker,
                title: title,
                imageFile: imageName,
                daykey: DayKey.current(),
                fold: .idle
            )
            if work.chosenField() != nil, !work.maker.isEmpty, !work.title.isEmpty, !work.imageFile.isEmpty {
                works.append(work)
            }
        }
        return works
    }

    private func nonempty(_ raw: String?) -> String? {
        let trimmed = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func filename(from imageURI: String?) -> String? {
        guard let imageURI, let last = imageURI.split(separator: "/").last else { return nil }
        return last.removingPercentEncoding ?? String(last)
    }

    func hydrate(id: String) async throws -> Work? {
        guard let url = URL(string: "https://www.wikidata.org/wiki/Special:EntityData/\(id).json") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        let data: Data
        do {
            (data, _) = try await carrier.data(for: request)
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch {
            throw CatalogFault.transport
        }
        let envelope: EntityDataDTO
        do {
            envelope = try decoder.decode(EntityDataDTO.self, from: data)
        } catch {
            throw CatalogFault.malformed
        }
        guard let entity = envelope.entities?[id] ?? envelope.entities?.values.first else { return nil }
        let maker = entity.makerQID.flatMap { $0 } 
        // Maker label is not always in EntityData claims; fall back to English title pairing.
        let title = entity.nativeTitle ?? entity.englishLabel ?? ""
        let makerName = entity.englishLabel.flatMap { title == $0 ? nil : $0 } ?? "National Gallery maker"
        // Prefer P170 entity id lookup from labels if present as sitelink-less claim; use accession.
        let resolvedMaker = makerLabel(from: entity) ?? makerName
        let image = entity.commonsFilename ?? ""
        let identity = entity.accession ?? entity.id ?? id
        let work = Work(
            id: entity.id ?? id,
            identity: identity,
            maker: resolvedMaker,
            title: title,
            imageFile: image,
            daykey: DayKey.current(),
            fold: .idle
        )
        let fieldReady = work.chosenField() != nil
        if work.maker.isEmpty || work.title.isEmpty || work.imageFile.isEmpty || !fieldReady {
            return nil
        }
        _ = maker
        return work
    }

    private func makerLabel(from entity: EntityDTO) -> String? {
        // EntityData often stores only a Q-id on P170. Prefer a human string if the claim leaked one.
        if let raw = entity.claims?["P170"]?.compactMap(\.stringValue).first,
           raw.hasPrefix("Q") == false,
           Stichos.tokens(in: raw).isEmpty == false {
            return raw
        }
        return nil
    }

    private func sparql(needle: String, limit: Int, offset: Int) -> String {
        let safe = needle.replacingOccurrences(of: "\"", with: "")
        return """
        SELECT DISTINCT ?item ?itemLabel ?makerLabel ?title ?accession ?image WHERE {
          ?item wdt:P195 wd:\(Self.collectionQID) .
          ?item wdt:P170 ?maker .
          ?item wdt:P18 ?image .
          OPTIONAL { ?item wdt:P1476 ?title . }
          OPTIONAL { ?item wdt:P217 ?accession . }
          SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
          FILTER(CONTAINS(LCASE(STR(?itemLabel)), LCASE("\(safe)")))
        }
        LIMIT \(limit)
        OFFSET \(offset)
        """
    }
}
