# elastic-query-builder
## Description

This gem provides a query builder class enabling you to generate elastic search queries (Json) using pure Ruby code. The query builder works similar to the well-known Doctrine2 query builder. Using query builders seems to make code more robust and provides the additional advantage of auto-completion in Ruby IDEs.

Usage

Build the gem using `gem build elastic-query-builder.gemspec`
Then install the gem using `gem install elastic-query-builder-0.0.0.gem`
Example code:
```ruby
require 'elastic-query-builder'

generatedQuery = ElasticQueryBuilder.new.
  search().withSize(0).
  withFilter().
    must(ElasticExpr.new.term(:term1, 'must occur')).
    must(ElasticExpr.new.range(:term2, '0', '2')).
    must_not(ElasticExpr.new.term(:term3, 'must not occur'))

puts generatedQuery.getJson
```
