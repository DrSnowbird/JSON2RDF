# JSON2RDF
Streaming generic JSON to RDF converter

Reads JSON data and streams N-Triples output. The conversion algorithm is similar to that of [JSON-LD](https://www.w3.org/TR/json-ld11-api/) but accepts arbitrary JSON and does not require a `@context`.

The resulting RDF representation is lossless with the exception of array ordering and some [datatype round-tripping](https://www.w3.org/TR/json-ld11-api/#data-round-tripping).
The lost ordering should not be a problem in the majority of cases, as RDF applications tend to impose their own value-based ordering using SPARQL `ORDER BY`.

A common use case is feeding the JSON2RDF output into a triplestore or SPARQL processor and using a SPARQL `CONSTRUCT` query to map the generic RDF to more specific RDF that uses terms from some vocabulary.
SPARQL is an inherently more flexible RDF mapping mechanism than JSON-LD `@context`.

## Build (Docker)

    make build

## Usage
```
json2rdf.sh -i <JSON_INPUT> [-o <TTL_OUTPUT>] [-b <BASE_URL>] [--input-charset <INPUT_CHARSET>] [--output-charset <OUTPUT_CHARSET>]

```
* `JSON_INPUT`: The JSON data 
* `TTL_OUTPUT`: The resulting RDF data is written in TTL.
* `BASE_URL`  : The base URI for the data. Property namespace is constructed by adding `#` to the base URI. Default is "https://localhost/"
Optional args:
* `--input-charset` - JSON input encoding, by default UTF-8
* `--output-charset` - RDF output encoding, by default UTF-8

## Examples
```
./json2rdf.sh -i json/city-distances.json 

./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test

./json2rdf.sh -i json/city-distances.json -v ontology/city-distances-vocab.txt

./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset=utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset=utf-8 --output-charset=utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --output-charset=utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --output-charset utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --output-charset=utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset=utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charsetutf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset utf-8
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset=utf-8 --output-charset=utf-16
./json2rdf.sh -i json/city-distances.json -b https://127.0.0.1/test --input-charset=utf-8 --output-charset=utf-8
```

***

Bob DuCharme's blog post on using JSON2RDF: [Converting JSON to RDF](http://www.bobdc.com/blog/json2rdf/).

***

JSON data in [`example.json`](https://www.w3.org/TR/json-ld11/#interpreting-json-as-json-ld)
```json
{
  "name": "Markus Lanthaler",
  "homepage": "http://www.markus-lanthaler.com/",
  "image": "http://twitter.com/account/profile_image/markuslanthaler"
}
```

Docker execution from shell:

    ./json2rdf.sh -i example.json

Turtle output

```turtle
[ <https://localhost/#homepage>  "http://www.markus-lanthaler.com/" ;
  <https://localhost/#image>     "http://twitter.com/account/profile_image/markuslanthaler" ;
  <https://localhost/#name>      "Markus Lanthaler"
] .
```

The following SPARQL query can be used to map this generic RDF to the desired target RDF, e.g. a structure that uses [schema.org](https://schema.org) vocabulary.

```sparql
BASE <https://localhost/>
PREFIX : <#>
PREFIX schema: <http://schema.org/>

CONSTRUCT
{
  ?person schema:homepage ?homepage ;
    schema:image ?image ;
    schema:name ?name .
}
{
  ?person :homepage ?homepageStr ;
    :image ?imageStr ;
    :name ?name .
  BIND (URI(?homepageStr) AS ?homepage)
  BIND (URI(?imageStr) AS ?image)
}
```

Turtle output after the mapping

```turtle
[ <http://schema.org/homepage>  <http://www.markus-lanthaler.com/> ;
  <http://schema.org/image>     <http://twitter.com/account/profile_image/markuslanthaler> ;
  <http://schema.org/name>      "Markus Lanthaler"
] .
```

***

JSON data in [`city-distances.json`](https://www.w3.org/TR/xslt-30/#json-to-xml-mapping)

```json
{
  "desc"    : "Distances between several cities, in kilometers.",
  "updated" : "2014-02-04T18:50:45",
  "uptodate": true,
  "author"  : null,
  "cities"  : {
    "Brussels": [
      {"to": "London",    "distance": 322},
      {"to": "Paris",     "distance": 265},
      {"to": "Amsterdam", "distance": 173}
    ],
    "London": [
      {"to": "Brussels",  "distance": 322},
      {"to": "Paris",     "distance": 344},
      {"to": "Amsterdam", "distance": 358}
    ],
    "Paris": [
      {"to": "Brussels",  "distance": 265},
      {"to": "London",    "distance": 344},
      {"to": "Amsterdam", "distance": 431}
    ],
    "Amsterdam": [
      {"to": "Brussels",  "distance": 173},
      {"to": "London",    "distance": 358},
      {"to": "Paris",     "distance": 431}
    ]
  }
}
```

Docker execution from shell:

    ./json2rdf.sh -i json/city-distances.json

Turtle output

```turtle
[ <https://localhost/#cities>    [ <https://localhost/#Amsterdam>  [ <https://localhost/#distance>  "431"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Paris"
                                                                   ] ;
                                   <https://localhost/#Amsterdam>  [ <https://localhost/#distance>  "358"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "London"
                                                                   ] ;
                                   <https://localhost/#Amsterdam>  [ <https://localhost/#distance>  "173"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Brussels"
                                                                   ] ;
                                   <https://localhost/#Brussels>   [ <https://localhost/#distance>  "322"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "London"
                                                                   ] ;
                                   <https://localhost/#Brussels>   [ <https://localhost/#distance>  "265"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Paris"
                                                                   ] ;
                                   <https://localhost/#Brussels>   [ <https://localhost/#distance>  "173"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Amsterdam"
                                                                   ] ;
                                   <https://localhost/#London>     [ <https://localhost/#distance>  "358"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Amsterdam"
                                                                   ] ;
                                   <https://localhost/#London>     [ <https://localhost/#distance>  "322"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Brussels"
                                                                   ] ;
                                   <https://localhost/#London>     [ <https://localhost/#distance>  "344"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Paris"
                                                                   ] ;
                                   <https://localhost/#Paris>      [ <https://localhost/#distance>  "431"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Amsterdam"
                                                                   ] ;
                                   <https://localhost/#Paris>      [ <https://localhost/#distance>  "344"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "London"
                                                                   ] ;
                                   <https://localhost/#Paris>      [ <https://localhost/#distance>  "265"^^<http://www.w3.org/2001/XMLSchema#int> ;
                                                                     <https://localhost/#to>        "Brussels"
                                                                   ]
                                 ] ;
  <https://localhost/#desc>      "Distances between several cities, in kilometers." ;
  <https://localhost/#updated>   "2014-02-04T18:50:45" ;
  <https://localhost/#uptodate>  true
] .
```

## Performance
(from upstream's Performance text - not by me)
Largest dataset tested so far: 2.95 GB / 30459482 lines of JSON to 4.5 GB / 21964039 triples in 2m10s.
Hardware: x64 Windows 10 PC with Intel Core i5-7200U 2.5 GHz CPU and 16 GB RAM.

## Dependencies

* [javax.json](https://mvnrepository.com/artifact/org.glassfish/javax.json)
* [Apache Jena](https://jena.apache.org/)
* [picocli](https://picocli.info)
