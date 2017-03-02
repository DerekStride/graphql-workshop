QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root for this schema'

  field :article do
    type ArticleType
    argument :id, !types.ID

    resolve -> (_, args, _) { Article.find(args[:id]) }
  end

  field :comment do
    type CommentType
    argument :id, !types.ID

    resolve -> (_, args, _) { Comment.find(args[:id]) }
  end

  field :simple do
    type SimpleType
    argument :id, !types.ID

    resolve -> (_, args, _) { OpenStruct.new(data: SecureRandom.uuid, id: args[:id]) }
  end
end
