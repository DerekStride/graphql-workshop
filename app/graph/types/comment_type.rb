CommentType = GraphQL::ObjectType.define do
  name 'Comment'
  description 'A Comment'
  global_id_field :id

  field :author, !types.String
  field :content, !types.String

  field :article do
    type ArticleType
    resolve -> (comment, _, _) { comment.article }
  end
end
