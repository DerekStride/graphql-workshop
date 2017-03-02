AddArticleMutation = GraphQL::Relay::Mutation.define do
  name 'CreateArticle'

  input_field :title, !types.String
  input_field :content, !types.String

  return_field :article, ArticleType

  resolve -> (_, inputs, _) do
    { article: Article.create!(title: inputs[:title], content: inputs[:content]) }
  end
end
