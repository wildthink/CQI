# CQI

``` swift
struct LocationSummary: Entity {
    var id: Int64
    var name: String
    var region: String
    var province: String
    var geocode: Geocode
}

@Query(.Place, .region(.us)) var locations: QueryResults<LocationSummary>

 View {
 }
 .environmentObject(DataStore(url: "memory:test")
```

