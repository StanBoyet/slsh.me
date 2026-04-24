require "test_helper"

class RedirectTest < ActionDispatch::IntegrationTest
  test "active link redirects to original URL" do
    get "/l/#{links(:active_link).slug}"
    assert_redirected_to links(:active_link).original_url
  end

  test "inactive link returns 410" do
    get "/l/#{links(:inactive_link).slug}"
    assert_response :gone
  end

  test "expired link returns 410" do
    get "/l/#{links(:expired_link).slug}"
    assert_response :gone
  end

  test "unknown slug returns 404" do
    get "/l/does-not-exist"
    assert_response :not_found
  end

  test "password-protected link shows password form" do
    get "/l/#{links(:password_link).slug}"
    assert_response :ok
    assert_select "form[action*='unlock']"
  end

  test "correct password redirects through" do
    post "/l/#{links(:password_link).slug}/unlock", params: { password: "hunter2" }
    assert_redirected_to links(:password_link).original_url
  end

  test "wrong password shows error" do
    post "/l/#{links(:password_link).slug}/unlock", params: { password: "wrong" }
    assert_response :unprocessable_entity
  end

  test "social bot gets OG preview page instead of redirect" do
    get "/l/#{links(:active_link).slug}",
        headers: { "HTTP_USER_AGENT" => "facebookexternalhit/1.1" }
    assert_response :ok
    assert_match %r{<meta property="og:title"}, response.body
    assert_no_match %r{302}, response.body
  end
end
