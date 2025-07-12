# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
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
