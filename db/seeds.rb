# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.first || User.create!(name: "テストユーザー", email: "test@example.com", password: "password")
Article.create!(
  title: "サンプル記事",
  body: "これはサンプルの記事です。",
  user: user
)