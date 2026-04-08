require "test_helper"

class LinksTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup { sign_in_as users(:one) }

  test "index lists user's links" do
    get links_path
    assert_response :ok
    assert_match "abc1234", response.body
  end

  test "index does not show other user's links" do
    get links_path
    assert_response :ok
    assert_no_match "other11", response.body
  end

  test "new renders form" do
    get new_link_path
    assert_response :ok
    assert_select "form"
  end

  test "create saves link and redirects to index" do
    assert_difference "Link.count" do
      post links_path, params: { link: { original_url: "https://rails.org" } }
    end
    assert_redirected_to links_path
  end

  test "create with invalid URL shows errors" do
    assert_no_difference "Link.count" do
      post links_path, params: { link: { original_url: "not-a-url" } }
    end
    assert_response :unprocessable_entity
  end

  test "analytics page renders without error" do
    get analytics_link_path(links(:active_link))
    assert_response :ok
  end

  test "analytics page renders with range param" do
    get analytics_link_path(links(:active_link), range: "7d")
    assert_response :ok
  end

  test "cannot access another user's link analytics" do
    get analytics_link_path(links(:other_user_link))
    assert_response :not_found
  end

  test "destroy deletes link" do
    assert_difference "Link.count", -1 do
      delete link_path(links(:active_link))
    end
    assert_redirected_to links_path
  end

  test "check_slug returns taken: true for existing slug" do
    get check_slug_links_path, params: { slug: links(:active_link).slug }
    assert_response :ok
    assert_equal({ "taken" => true }, JSON.parse(response.body))
  end

  test "check_slug returns taken: false for new slug" do
    get check_slug_links_path, params: { slug: "brandnewslug" }
    assert_response :ok
    assert_equal({ "taken" => false }, JSON.parse(response.body))
  end

  test "unauthenticated access redirects to login" do
    sign_out
    get links_path
    assert_redirected_to new_session_path
  end
end
