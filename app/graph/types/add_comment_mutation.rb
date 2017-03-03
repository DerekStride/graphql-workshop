AddCommentMutation = GraphQL::Relay::Mutation.define do
  name 'CreateComment'

  input_field :author, !types.String
  input_field :content, !types.String
  input_field :article_id, !types.ID

  return_field :comment, CommentType

  resolve -> (_, inputs, _) do
    article = Article.find(inputs[:article_id])
    { comment: article.comments.create!(author: inputs[:author], content: inputs[:content]) }
  end
end
