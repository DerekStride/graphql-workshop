Rails.application.routes.draw do
  post '/graphql', to: 'graphql#create'
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: '/graphql'
end
