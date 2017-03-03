ArticleType = GraphQL::ObjectType.define do
  name 'Article'
  description 'An Article'
  global_id_field :id

  field :title, !types.String
  field :content, !types.String

  connection :comments do
    type CommentType.connection_type
    resolve -> (article, _, _) { article.comments }
  end
end
