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

  test "new renders the create form" do
    get new_campaign_path
    assert_response :ok
    assert_match "New campaign", response.body
  end

  test "create via HTML redirects to show" do
    assert_difference "Campaign.count" do
      post campaigns_path, params: { campaign: { name: "Spring Burst", color: "violet" } }
    end
    assert_redirected_to campaign_path(Campaign.last)
  end

  test "edit renders the settings form" do
    get edit_campaign_path(campaigns(:q2_launch))
    assert_response :ok
    assert_match "Campaign settings", response.body
    assert_match "Social preview", response.body
  end

  test "update saves new fields" do
    campaign = campaigns(:q2_launch)
    patch campaign_path(campaign), params: {
      campaign: {
        name: campaign.name,
        slug: campaign.slug,
        color: campaign.color,
        destination_url: "https://example.com/launch",
        title: "Custom OG",
        description: "Be there",
        goal_clicks: 5000,
        starts_at: 1.day.ago.iso8601,
        ends_at: 7.days.from_now.iso8601
      }
    }
    assert_redirected_to campaign_path(campaign)
    campaign.reload
    assert_equal "https://example.com/launch", campaign.destination_url
    assert_equal "Custom OG", campaign.title
    assert_equal 5000, campaign.goal_clicks
  end

  test "update_channels creates new links with assembled UTMs" do
    campaign = @user_campaign = campaigns(:newsletter)
    campaign.update!(destination_url: "https://example.com/article")

    assert_difference "campaign.links.count", 2 do
      post update_channels_campaign_path(campaign),
           params: {
             destination_url: campaign.destination_url,
             channels: [
               { client_id: "c1", utm_source: "twitter",  utm_medium: "social", slug: "newjul-tw" },
               { client_id: "c2", utm_source: "linkedin", utm_medium: "social", slug: "newjul-li" }
             ]
           },
           as: :json
    end
    assert_response :ok

    twitter = campaign.links.find_by(slug: "newjul-tw")
    assert_includes twitter.original_url, "utm_source=twitter"
    assert_includes twitter.original_url, "utm_medium=social"
    assert_includes twitter.original_url, "utm_campaign=#{campaign.slug}"
    assert_includes twitter.original_url, "https://example.com/article"
  end

  test "update_channels updates an existing link's slug + UTMs" do
    campaign = campaigns(:q2_launch)
    campaign.update!(destination_url: "https://example.com/pricing")
    link = links(:campaign_link)

    post update_channels_campaign_path(campaign),
         params: {
           destination_url: campaign.destination_url,
           channels: [ { id: link.id, utm_source: "facebook", utm_medium: "social", slug: link.slug } ]
         },
         as: :json
    assert_response :ok

    link.reload
    assert_includes link.original_url, "utm_source=facebook"
    assert_includes link.original_url, "utm_campaign=#{campaign.slug}"
  end

  test "update_channels destroys flagged rows" do
    campaign = campaigns(:q2_launch)
    campaign.update!(destination_url: "https://example.com/pricing")
    link = links(:campaign_link)

    assert_difference "Link.count", -1 do
      post update_channels_campaign_path(campaign),
           params: {
             destination_url: campaign.destination_url,
             channels: [ { id: link.id, _destroy: "1" } ]
           },
           as: :json
    end
  end

  test "update_channels rejects when destination_url missing" do
    campaign = campaigns(:newsletter) # no destination_url set
    post update_channels_campaign_path(campaign),
         params: { channels: [ { utm_source: "x", utm_medium: "y", slug: "z" } ] },
         as: :json
    assert_response :unprocessable_entity
  end

  test "show pre-seeds matrix rows for empty campaign" do
    campaign = campaigns(:newsletter)
    get campaign_path(campaign)
    assert_response :ok
    # Pre-seeded rows render Meta/LinkedIn/Newsletter slug suggestions prefixed by the campaign slug
    assert_match "#{campaign.slug}-meta",     response.body
    assert_match "#{campaign.slug}-linkedin", response.body
  end

  test "fetch_og endpoint returns JSON" do
    OgFetcherService.any_instance.stubs(:call).returns({ title: "Hi", description: "World" }) rescue nil
    post fetch_og_campaigns_path, params: { url: "https://example.com" }, as: :json
    assert_response :ok
  end
end
