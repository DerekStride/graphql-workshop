SimpleType = GraphQL::ObjectType.define do
  name 'Simple'

  field :id, !types.ID
  field :data, !types.String
end
