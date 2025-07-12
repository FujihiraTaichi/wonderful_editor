# == Schema Information
#
# Table name: article_likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_article_likes_on_article_id  (article_id)
#  index_article_likes_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Article, type: :model do
  it "is valid with a title and body" do
    article = build(:article)
    expect(article).to be_valid
  end

  it "is invalid without a title" do
    article = build(:article, title: nil)
    expect(article).not_to be_valid
  end

  it "is invalid without a body" do
    article = build(:article, body: nil)
    expect(article).not_to be_valid
  end
end
