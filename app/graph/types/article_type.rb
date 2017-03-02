ArticleType = GraphQL::ObjectType.define do
  name 'Article'
  description 'An Article'

  field :id, !types.ID
  field :title, !types.String
  field :content, !types.String
end
