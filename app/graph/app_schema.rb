AppSchema = GraphQL::Schema.define do
  query QueryType

  resolve_type -> (_) { binding.pry }
end
