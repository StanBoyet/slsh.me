require "test_helper"

class CustomDomainRedirectTest < ActionDispatch::IntegrationTest
  setup do
    ENV["APP_HOST"] = "www.example.com"
  end

  teardown do
    ENV.delete("APP_HOST")
  end

  test "custom domain resolves its own link" do
    get "/l/promo", headers: { "HOST" => "links.example.com" }
    assert_redirected_to links(:custom_domain_link).original_url
  end

  test "custom domain does not resolve slsh.me links" do
    get "/l/#{links(:active_link).slug}", headers: { "HOST" => "links.example.com" }
    assert_response :not_found
  end

  test "slsh.me does not resolve custom domain links" do
    get "/l/promo"
    assert_response :not_found
  end

  test "same slug can exist on different domains" do
    # "promo" exists on links.example.com via fixture
    # Create another "promo" on the default domain
    user = users(:one)
    user.links.create!(original_url: "https://default.example.com", slug: "promo")

    get "/l/promo"
    assert_redirected_to "https://default.example.com"

    get "/l/promo", headers: { "HOST" => "links.example.com" }
    assert_redirected_to "https://example.com/custom"
  end

  test "archived link returns 410" do
    get "/l/#{links(:archived_link).slug}"
    assert_response :gone
  end

  test "custom domain request to app routes redirects to primary host" do
    get "/links", headers: { "HOST" => "links.example.com" }
    assert_redirected_to "https://www.example.com"
  end

  test "custom domain request to session routes redirects to primary host" do
    get "/session/new", headers: { "HOST" => "links.example.com" }
    assert_redirected_to "https://www.example.com"
  end
end
