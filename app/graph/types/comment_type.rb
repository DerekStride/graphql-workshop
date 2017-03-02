CommentType = GraphQL::ObjectType.define do
  name 'Comment'
  description 'A Comment'

  field :id, !types.ID
  field :author, !types.String
  field :content, !types.String
end
