require "test_helper"

class CampaignsTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup { sign_in_as users(:one) }

  test "show renders campaign detail page" do
    get campaign_path(campaigns(:q2_launch))
    assert_response :ok
    assert_match "Q2 Product Launch", response.body
  end

  test "show renders with range param" do
    get campaign_path(campaigns(:q2_launch), range: "7d")
    assert_response :ok
  end

  test "cannot view another user's campaign" do
    get campaign_path(campaigns(:other_user_campaign))
    assert_response :not_found
  end

  test "create campaign via JSON" do
    assert_difference "Campaign.count" do
      post campaigns_path(format: :json),
           params: { campaign: { name: "Black Friday", color: "rose" } },
           as: :json
    end
    assert_response :ok
    data = JSON.parse(response.body)
    assert_equal "Black Friday", data["name"]
    assert_equal "black-friday", data["slug"]
    assert_equal "rose", data["color"]
  end

  test "create campaign with invalid data returns errors" do
    assert_no_difference "Campaign.count" do
      post campaigns_path(format: :json),
           params: { campaign: { name: "" } },
           as: :json
    end
    assert_response :unprocessable_entity
  end

  test "destroy removes campaign and nullifies links" do
    campaign = campaigns(:q2_launch)
    link = links(:campaign_link)

    assert_difference "Campaign.count", -1 do
      delete campaign_path(campaign)
    end
    assert_redirected_to links_path
    assert_nil link.reload.campaign_id
  end

  test "links index shows campaign filter" do
    get links_path
    assert_response :ok
    assert_match "Q2 Product Launch", response.body
  end

  test "links index filters by campaign" do
    get links_path(campaign_id: campaigns(:q2_launch).id)
    assert_response :ok
    assert_match "q2tweet", response.body
  end

  test "create link with campaign_id" do
    campaign = campaigns(:q2_launch)
    assert_difference "Link.count" do
      post links_path, params: {
        link: { original_url: "https://example.com/new", campaign_id: campaign.id }
      }
    end
    assert_equal campaign.id, Link.last.campaign_id
  end
end
