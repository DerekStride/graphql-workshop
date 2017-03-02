QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root for this schema'

  field :simple do
    type SimpleType
    argument :id, !types.ID

    resolve -> (_, args, _) { OpenStruct.new(data: SecureRandom.uuid, id: args[:id]) }
  end
end
