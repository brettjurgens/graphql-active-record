ProductType = GraphQL::ObjectType.define do
  name "Product"

  field :id, types.ID
  field :name, types.String
  field :customer, -> { CustomerType }
end

CustomerType = GraphQL::ObjectType.define do
  name "Customer"

  field :id, types.ID
  field :name, types.String
  field :product, -> { ProductType }
end

QueryType = GraphQL::ObjectType.define do
  name "Query"
  field :customer, CustomerType, field: GraphQL::ActiveRecordExtensions::Field.new(type: CustomerType, model: Customer)
end

Schema = GraphQL::Schema.new(query: QueryType)
