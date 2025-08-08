# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default("draft"), not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_status   (status)
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

  describe "status" do
    it "下書き記事として保存できる" do
      article = build(:article, status: :draft)
      expect(article).to be_valid
      article.save!
      expect(article.draft?).to be_truthy
    end

    it "公開記事として保存できる" do
      article = build(:article, status: :published)
      expect(article).to be_valid
      article.save!
      expect(article.published?).to be_truthy
    end
  end
end
