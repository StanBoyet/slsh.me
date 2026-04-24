require "test_helper"

class DomainChecksTest < ActionDispatch::IntegrationTest
  test "returns 200 for a registered custom domain" do
    get domain_check_path, params: { domain: custom_domains(:example_domain).domain }
    assert_response :ok
  end

  test "returns 404 for an unknown domain" do
    get domain_check_path, params: { domain: "random.example.org" }
    assert_response :not_found
  end

  test "returns 404 when domain param is missing" do
    get domain_check_path
    assert_response :not_found
  end

  test "normalises the domain (case-insensitive match)" do
    get domain_check_path, params: { domain: custom_domains(:example_domain).domain.upcase }
    assert_response :ok
  end
end
