MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'The mutation root for this schema'

  field :addArticle, field: AddArticleMutation.field
end
