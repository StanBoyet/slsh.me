require "test_helper"

class CustomDomainTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid domain saves" do
    domain = @user.custom_domains.build(domain: "new.example.com")
    assert domain.save
  end

  test "domain must be present" do
    domain = @user.custom_domains.build(domain: "")
    assert_not domain.valid?
    assert_includes domain.errors[:domain], "can't be blank"
  end

  test "domain must be unique" do
    dup = @user.custom_domains.build(domain: custom_domains(:example_domain).domain)
    assert_not dup.valid?
    assert_includes dup.errors[:domain], "has already been taken"
  end

  test "domain is normalized to lowercase" do
    domain = @user.custom_domains.create!(domain: "UPPER.Example.COM")
    assert_equal "upper.example.com", domain.domain
  end

  test "invalid domain format rejected" do
    domain = @user.custom_domains.build(domain: "not a domain!")
    assert_not domain.valid?
  end

  test "archive_links! archives all domain links" do
    domain = custom_domains(:example_domain)
    link = links(:custom_domain_link)

    assert link.active?
    assert_not link.archived?

    domain.archive_links!
    link.reload

    assert link.archived?
    assert_not link.active?
    assert_nil link.custom_domain_id
  end
end
