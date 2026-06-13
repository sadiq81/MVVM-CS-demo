import Vapor
import Fluent
import Foundation

struct ProductController: RouteCollection {
    
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.group("products") { dashboard in
            
            dashboard.group(UserAuthenticator()) { authenticated in
                authenticated.get("", use: self.products)
                authenticated.get("filters", use: self.filters)
            }
        }
    }
    
    private func products(_ req: Request) async throws -> ProductPaginatedResponse {
        
        let productRequest = try await req.client.get("https://dummyjson.com/products?limit=0")
        
        var response = try productRequest.content.decode(ProductPaginatedResponse.self)
        var products = response.products
        
        let parameters = try req.query.decode(ProductParameters.self)
        
        if let search = parameters.search {
            products = products.filter({ $0.search.contains(search) })
        }
        
        if let categories: String = parameters.categories, !categories.isEmpty {
            let categoryList: [String] = categories.split(separator: ",").map(String.init)
            products = products.filter({ categoryList.contains($0.category) })
        }
        
        if let brands  = parameters.brands, !brands.isEmpty {
            let brandsList: [String] = brands.split(separator: ",").map(String.init)
            products = products.filter({ product in
                guard let brand = product.brand else { return false }
                return brandsList.contains(brand)})
        }
        
        // Pagination slices this sorted array per page (skip/limit), and every page
        // request re-runs this whole pipeline. Sorting on `brand` alone is not a total
        // order — the many products that share a brand (or have no brand at all) tie,
        // and Swift's sort gives no stability guarantee, so tied items can be ordered
        // differently between requests. That reshuffles page boundaries and causes
        // items to be duplicated or skipped while paging. Add the unique `id` as a
        // tiebreaker so the order is total, deterministic, and identical on every
        // request — and matches the app, which orders by brand then id.
        products = products.sorted(by: { ($0.brand ?? "", $0.id) < ($1.brand ?? "", $1.id) })
        
        response.total = products.count
        response.skip = parameters.skip
        response.limit = parameters.limit
        
        let skipped = products.suffix(from: parameters.skip)
        let limited = skipped.prefix(response.limit)
        
        response.products = Array(limited)
        
        return response
    }
    
    private func filters(_ req: Request) async throws -> FilterResponse {
        
        let productRequest = try await req.client.get("https://dummyjson.com/products?limit=0")
        
        let brandsResponse = try productRequest.content.decode(ProductPaginatedResponse.self)
        let brands = Array(brandsResponse.products.compactMap { $0.brand }.uniqued())
        
        let categoriesRequest = try await req.client.get("https://dummyjson.com/products/categories")
        let categories = try categoriesRequest.content.decode([CategoryResponse].self).map { $0.slug }
        
        let filterResponse = FilterResponse(categories: categories, brands: brands)
        return filterResponse
        
    }
}

struct FilterResponse: Content {
    
    var categories: [String]
    var brands: [String]
    
}
