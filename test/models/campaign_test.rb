require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid campaign saves" do
    campaign = @user.campaigns.build(name: "Summer Sale")
    assert campaign.save
    assert_equal "summer-sale", campaign.slug
  end

  test "name is required" do
    campaign = @user.campaigns.build(name: "")
    assert_not campaign.valid?
    assert_includes campaign.errors[:name], "can't be blank"
  end

  test "slug auto-generates from name" do
    campaign = @user.campaigns.create!(name: "Q3 Product Launch")
    assert_equal "q3-product-launch", campaign.slug
  end

  test "slug must be unique per user" do
    @user.campaigns.create!(name: "Test", slug: "test-slug")
    dup = @user.campaigns.build(name: "Test 2", slug: "test-slug")
    assert_not dup.valid?
    assert_includes dup.errors[:slug], "has already been taken"
  end

  test "same slug allowed for different users" do
    @user.campaigns.create!(name: "Test", slug: "shared-slug")
    other = users(:two).campaigns.build(name: "Test", slug: "shared-slug")
    assert other.valid?
  end

  test "color must be valid" do
    campaign = @user.campaigns.build(name: "Bad", color: "magenta")
    assert_not campaign.valid?
    assert campaign.errors[:color].any?
  end

  test "default color is orange" do
    campaign = @user.campaigns.create!(name: "Defaulted")
    assert_equal "orange", campaign.color
  end

  test "links_count counter cache works" do
    campaign = @user.campaigns.create!(name: "Counter Test")
    assert_equal 0, campaign.links_count
    @user.links.create!(original_url: "https://example.com", campaign: campaign)
    assert_equal 1, campaign.reload.links_count
  end

  test "with_clicks_count scope aggregates clicks" do
    campaign = Campaign.with_clicks_count.find(campaigns(:q2_launch).id)
    assert_equal 42, campaign.computed_clicks_count
  end

  test "destroying campaign nullifies links" do
    campaign = campaigns(:q2_launch)
    link = links(:campaign_link)
    campaign.destroy
    link.reload
    assert_nil link.campaign_id
  end
end
