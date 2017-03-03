# GraphQL

If you want to build the app piece by piece clone the repo `git clone https://github.com/DerekStride/graphql-workshop.git` and reset to the base rails app with a standard blog app configured `git checkout 13cacb5 -b workshop`.

The application at that point has an Article and a Comment ActiveRecord models setup and a few changes in the routes and application config files. It also has some seed data to create some records for us to use.

```
rake db:migrate
rake db:seed
```

## Step 1 - Setup the GraphQL Controller

Create a controller that will accept our graphql queries, you'll probably need to create an api controller too.

```ruby
# app/controllers/api_controller.rb
class ApiController < ActionController::Base
  protect_from_forgery with: :null_session
end
```

```ruby
# app/controllers/graphql_controller.rb
class GraphqlController < ApiController
  def create
    query_string = params[:query]
    query_variables = ensure_hash(params[:variables])
    result = AppSchema.execute(query_string, variables: query_variables)
    render json: result
  end

  private

  def ensure_hash(query_variables)
    if query_variables.blank?
      {}
    elsif query_variables.is_a?(String)
      JSON.parse(query_variables)
    else
      query_variables
    end
  end
end
```

## Step 2 - Creating a Schema

Create the AppSchema class that we refer to in the controller above.

```ruby
# app/graph/app_schema.rb
AppSchema = GraphQL::Schema.define do
  query QueryType
end
```

The schema is the entry point to the API it defines 2 types, a query root for retrieving data and a mutation type for modifying data. First we're going to create the query root.

```ruby
# app/graph/types/query_type.rb
QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root for this schema'

  field :simple do
    type SimpleType
    argument :id, !types.ID

    resolve -> (_, args, _) { OpenStruct.new(data: SecureRandom.uuid, id: args[:id]) }
  end
end

```

We'll also want to define an example type to get up running.

```ruby
# app/graph/types/simple_type.rb
SimpleType = GraphQL::ObjectType.define do
  name 'Simple'

  field :id, !types.ID
  field :data, !types.String
end
```

Now we can make a request to our graphql API via the GraphiQL editor at `/graphiql`

```graphql
query {
	simple(id: 1) {
    id
    data
  }
}
```

## Step 3 - ArticleType and CommentType

Lets add types for our Article model and our Comment model

```ruby
# app/graph/types/article_type.rb
ArticleType = GraphQL::ObjectType.define do
  name 'Article'
  description 'An Article'

  field :id, !types.ID
  field :title, !types.String
  field :content, !types.String
end
```

```ruby
# app/graph/types/comment_type.rb
CommentType = GraphQL::ObjectType.define do
  name 'Comment'
  description 'A Comment'

  field :id, !types.ID
  field :author, !types.String
  field :content, !types.String
end
```

Now we need to add them to the query root so that we can access them.

```ruby
# app/graph/types/query_type.rb
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
```

Now try the following query

```graphql
query {
  article(id: 1) {
    title
    content
  }
  comment(id: 1) {
    author
    content
  }
}
```

## Step 4 - Associations and GraphQL connections

To represent the has many relationship between articles and comments we need to add a connection field to our Article type and an article field to comments

```ruby
# app/graph/types/article_type.rb
ArticleType = GraphQL::ObjectType.define do
  name 'Article'
  description 'An Article'

  field :id, !types.ID
  field :title, !types.String
  field :content, !types.String

  connection :comments do
    type CommentType.connection_type
    resolve -> (article, _, _) { article.comments }
  end
end
```

```ruby
# app/graph/types/comment_type.rb
CommentType = GraphQL::ObjectType.define do
  name 'Comment'
  description 'A Comment'

  field :id, !types.ID
  field :author, !types.String
  field :content, !types.String

  field :article do
    type ArticleType
    resolve -> (comment, _, _) { comment.article }
  end
end
```

Now try the following query

```graphql
query {
	simple(id: 1) {
    id
    data
  }
  article(id: 1) {
    title
    content
    comments(first: 2) {
      edges {
        cursor
        node {
          author
          content
        }
      }
    }
  }
  comment(id: 1) {
    author
    content
    article {
      title
    }
  }
}
```

## Step 5 - Mutations

The first thing we need to do before creating a mutation is add the mutation root to our schema

```ruby
# app/graph/app_schema.rb
AppSchema = GraphQL::Schema.define do
  query QueryType
  mutation MutationType
end
```

```ruby
# app/graph/types/mutation_type.rb
MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'The mutation root for this schema'

  field :addArticle, field: AddArticleMutation.field
  field :addComment, field: AddCommentMutation.field
end
```

Next we'll need to create the Add Article and Comment mutation types

```ruby
# app/graph/types/add_comment_mutation.rb
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
```

```ruby
# app/graph/types/add_article_mutation.rb
AddArticleMutation = GraphQL::Relay::Mutation.define do
  name 'CreateArticle'

  input_field :title, !types.String
  input_field :content, !types.String

  return_field :article, ArticleType

  resolve -> (_, inputs, _) do
    { article: Article.create!(title: inputs[:title], content: inputs[:content]) }
  end
end
```

Now you can try the following mutations

```graphql
mutation createArticle {
  addArticle(input: { title: "Hello, World!", content: "My first Mutation" }) {
    article {
      content
      title
    }
  }
}
```

```graphql
mutation createComment {
  addComment(input: { content: "Great Work!", author: "Me", article_id: 2 }) {
    comment {
      author
      content
      article {
        title
      }
    }
  }
}
```
