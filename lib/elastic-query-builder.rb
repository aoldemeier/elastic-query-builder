# Main module containing query builder and helper classes

require 'json'

class ElasticQueryBuilder

  def initialize(builder=nil)
    if builder == nil then
      @queryAsHash = {}
      @cursor = @queryAsHash
    else
      @queryAsHash = builder.queryAsHash
      @cursor = builder.cursor
    end
  end

  attr_reader :queryAsHash
  attr_reader :cursor

  def getJson()
    @queryAsHash.to_json
  end

  def search()
    ElasticQueryBuilderFilter.new(self)
  end

  private

  def walk(from, *symchain)
    @cursor = from
    symchain.each do |sym|
      if @cursor[sym] == nil then @cursor[sym] = {} end
      @cursor = @cursor[sym]
    end
  end

end

# This class is the first stage of a query builder
class ElasticQueryBuilderFilter < ElasticQueryBuilder

  def withSize(size)
    @queryAsHash = @queryAsHash.merge({:size => size})
    self
  end

  def withFilter()
    walk(@queryAsHash, :query, :filtered)
    @cursor[:filter] = {}
    self
  end

  def must_gen(modal, expr)
    if @cursor[:filter][:bool] == nil then @cursor[:filter][:bool] = {} end
    @cursor[:filter][:bool][modal] = if @cursor[:filter][:bool][modal].kind_of?(Array) then
                                       @cursor[:filter][:bool][modal] << expr
                                     else
                                       [expr]
                                     end
    self
  end

  def must(expr)
    must_gen(:must, expr)
  end

  def must_not(expr)
    must_gen(:must_not, expr)
  end

  def sortBy(field, sortOrder, type)
    @queryAsHash = @queryAsHash.merge(
        {:sort => [{field => {:order => sortOrder, :unmapped_type => type}}]}
    )
    @cursor = @queryAsHash[:sort]
    self
  end

  def aggregate()
    walk(@queryAsHash, :aggregations)
    ElasticQueryBuilderAggregate.new(self)
  end
end

#This class is returned after a query builder has been marked for aggregation
class ElasticQueryBuilderAggregate < ElasticQueryBuilder

  def withHistogram(name, field, interval, key, sortOrder, timeZoneOffset)
    @cursor[:histogram] = {name => {:field => field, :interval => interval, :order => {key => sortOrder}, :time_zone => timeZoneOffset}}
    self
  end

  def withAggregateFilter(filterName)
    walk(@queryAsHash[:aggregations], :histogram, :aggregations, :requests, :filters, :filters, filterName)
    @cursor[:query] = {}
    self
  end

  def wildcard(wc)
    @cursor[:query] = @cursor[:query].merge({:wildcard => {:path => {:value => wc}}})
    self
  end

  def withAgg(name)
    walk(@queryAsHash[:aggregations], :histogram, :aggregations, :requests, :aggs, name)
    self
  end

  def percentile(field, percents)
    if @cursor[:percentiles] == nil then @cursor[:percentiles] = {} end
    @cursor[:percentiles] = @cursor[:percentiles].merge({:field => field, :percents => [percents]})
    self
  end
end

class ElasticExpr
  def term(label, value)
    return {:term => {label => value}}
  end

  def range(label, lowerBound, upperBound)
    return {:range => {label => {:gte => lowerBound, :lte => upperBound}}}
  end

  def self.now()
    'now'
  end
end

class ElasticType
  def self.long()
    'long'
  end
end

class ElasticSortOrder
  def self.ascending()
    'asc'
  end
  def self.descending()
    'desc'
  end
end
