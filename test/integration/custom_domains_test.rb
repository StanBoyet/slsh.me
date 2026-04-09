require "test_helper"

class CustomDomainsTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup { sign_in_as users(:one) }

  test "index lists custom domains" do
    get custom_domains_path
    assert_response :ok
    assert_match "links.example.com", response.body
  end

  test "create adds a domain" do
    assert_difference "CustomDomain.count" do
      post custom_domains_path, params: { custom_domain: { domain: "new.example.com" } }
    end
    assert_redirected_to custom_domains_path
  end

  test "create with invalid domain shows errors" do
    assert_no_difference "CustomDomain.count" do
      post custom_domains_path, params: { custom_domain: { domain: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "destroy archives links and removes domain" do
    domain = custom_domains(:example_domain)
    link = links(:custom_domain_link)

    assert_difference "CustomDomain.count", -1 do
      delete custom_domain_path(domain)
    end

    link.reload
    assert link.archived?
    assert_not link.active?
    assert_nil link.custom_domain_id
    assert_redirected_to custom_domains_path
  end
end
