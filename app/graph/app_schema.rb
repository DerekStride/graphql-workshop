AppSchema = GraphQL::Schema.define do
  query QueryType
  mutation MutationType

  resolve_type -> (_) { binding.pry }
end
