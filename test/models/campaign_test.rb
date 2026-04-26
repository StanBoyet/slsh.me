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

  test "destination_url validates as HTTP/HTTPS URL" do
    campaign = @user.campaigns.build(name: "URL", destination_url: "not a url")
    assert_not campaign.valid?
    assert campaign.errors[:destination_url].any?

    campaign.destination_url = "https://example.com/launch"
    assert campaign.valid?, campaign.errors.full_messages.inspect
  end

  test "destination_url is optional" do
    campaign = @user.campaigns.build(name: "URL")
    assert campaign.valid?
  end

  test "ends_at must come after starts_at" do
    campaign = @user.campaigns.build(name: "Range",
      starts_at: 1.day.from_now, ends_at: 1.day.ago)
    assert_not campaign.valid?
    assert campaign.errors[:ends_at].any?
  end

  test "og_title falls back to name" do
    campaign = @user.campaigns.create!(name: "Launch")
    assert_equal "Launch", campaign.og_title

    campaign.update!(title: "Custom OG title")
    assert_equal "Custom OG title", campaign.og_title
  end

  test "goal_progress returns nil without a goal" do
    campaign = @user.campaigns.create!(name: "No goal")
    assert_nil campaign.goal_progress(100)
  end

  test "goal_progress reports clicks, target, percent" do
    campaign = @user.campaigns.create!(name: "Goal", goal_clicks: 1000)
    progress = campaign.goal_progress(250)
    assert_equal 250,  progress[:clicks]
    assert_equal 1000, progress[:target]
    assert_equal 25,   progress[:percent]
  end

  test "goal_progress percent clamps to 100" do
    campaign = @user.campaigns.create!(name: "Over", goal_clicks: 100)
    assert_equal 100, campaign.goal_progress(500)[:percent]
  end

  test "pace_delta returns nil without goal or end date" do
    campaign = @user.campaigns.create!(name: "Pace")
    assert_nil campaign.pace_delta(100)

    campaign.update!(goal_clicks: 1000)
    assert_nil campaign.pace_delta(100)
  end

  test "pace_delta is positive when ahead of straight-line target" do
    campaign = @user.campaigns.create!(
      name: "Ahead",
      goal_clicks: 1000,
      starts_at: 10.days.ago,
      ends_at: 10.days.from_now
    )
    # Halfway through, expected ≈ 500. Actual = 700 → ~+200.
    delta = campaign.pace_delta(700)
    assert delta > 100, "expected delta > 100, got #{delta}"
  end

  test "pace_delta is negative when behind" do
    campaign = @user.campaigns.create!(
      name: "Behind",
      goal_clicks: 1000,
      starts_at: 10.days.ago,
      ends_at: 10.days.from_now
    )
    delta = campaign.pace_delta(100)
    assert delta < 0
  end
end
