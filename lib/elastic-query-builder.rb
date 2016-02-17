require 'json'

class ElasticQueryBuilder
 
  def initialize()
    @queryAsHash = {}
    @cursor = @queryAsHash
  end

  def getJson()
    @queryAsHash.to_json
  end

  def search()
    @queryAsHash = @queryAsHash.merge({:_search => {}})
    @cursor = @queryAsHash[:_search]
    return self 
  end

  def withSize(size)
    @queryAsHash[:_search] = @queryAsHash[:_search].merge({:size => size})
    return self
  end

  def withFilter()
    @queryAsHash[:_search] = @queryAsHash[:_search].merge({:query => {:filtered => {:filter => {}}}})
    @cursor = @queryAsHash[:_search][:query][:filtered]
    return self
  end

  def must_gen(modal, expr)
    if @cursor[:filter][:bool] == nil then @cursor[:filter][:bool] = {} end
    @cursor[:filter][:bool][modal] = if @cursor[:filter][:bool][modal].kind_of?(Array) then
                                @cursor[:filter][:bool][modal] << expr 
                              else
                                [expr]
                              end 
    return self
  end
  
  def must(expr)
    must_gen(:must, expr)
  end

  def must_not(expr)
    must_gen(:must_not, expr)
  end
  
  def withAggs()
    # ...
  end
end

class ElasticExpr
  def term(label, value)
    return {:term => {label => value}}
  end

  def range(label, lowerBound, upperBound)
    return {:range => {label => {:gte => lowerBound, :lte => upperBound}}}
  end
end
