require "test_helper"

class CustomDomainRedirectTest < ActionDispatch::IntegrationTest
  setup do
    ENV["APP_HOST"] = "www.example.com"
  end

  teardown do
    ENV.delete("APP_HOST")
  end

  # Custom domain links resolve at root path (no /l/ prefix)
  test "custom domain resolves link at root path" do
    get "/#{links(:custom_domain_link).slug}", headers: { "HOST" => "links.example.com" }
    assert_redirected_to links(:custom_domain_link).original_url
  end

  test "custom domain does not resolve slsh.me links" do
    get "/#{links(:active_link).slug}", headers: { "HOST" => "links.example.com" }
    assert_response :not_found
  end

  # slsh.me links still use /l/ prefix
  test "slsh.me resolves link at /l/ path" do
    get "/l/#{links(:active_link).slug}"
    assert_redirected_to links(:active_link).original_url
  end

  test "slsh.me does not resolve custom domain links" do
    get "/l/promo"
    assert_response :not_found
  end

  test "same slug can exist on different domains" do
    user = users(:one)
    user.links.create!(original_url: "https://default.example.com", slug: "promo")

    # slsh.me uses /l/ prefix
    get "/l/promo"
    assert_redirected_to "https://default.example.com"

    # Custom domain uses root path
    get "/promo", headers: { "HOST" => "links.example.com" }
    assert_redirected_to "https://example.com/custom"
  end

  test "archived link returns 410" do
    get "/l/#{links(:archived_link).slug}"
    assert_response :gone
  end

  # Custom domain password unlock also at root
  test "custom domain password unlock at root path" do
    link = links(:custom_domain_link)
    link.update!(password: "secret123")

    get "/#{link.slug}", headers: { "HOST" => "links.example.com" }
    assert_response :ok
    assert_select "form[action*='unlock']"

    post "/#{link.slug}/unlock", headers: { "HOST" => "links.example.com" }, params: { password: "secret123" }
    assert_redirected_to link.original_url
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
