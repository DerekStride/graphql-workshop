AppSchema = GraphQL::Schema.define do
  query QueryType
  mutation MutationType

  id_from_object ->(object, _, _) { object.to_global_id.to_s }
  object_from_id ->(id, _) { GlobalID::Locator.locate id }
  resolve_type -> (_) { binding.pry }
end
