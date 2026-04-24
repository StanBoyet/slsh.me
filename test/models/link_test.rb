require "test_helper"

class LinkTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid link saves with auto-generated slug" do
    link = @user.links.build(original_url: "https://example.com")
    assert link.save
    assert link.slug.present?
    assert_match(/\A[a-z0-9]{7}\z/, link.slug)
  end

  test "custom slug is preserved" do
    link = @user.links.create!(original_url: "https://example.com", slug: "myslug")
    assert_equal "myslug", link.slug
  end

  test "slug must be unique" do
    @user.links.create!(original_url: "https://example.com", slug: "taken")
    dup = @user.links.build(original_url: "https://example.com", slug: "taken")
    assert_not dup.valid?
    assert_includes dup.errors[:slug], "has already been taken"
  end

  test "slug rejects reserved words" do
    link = @user.links.build(original_url: "https://example.com", slug: "session")
    assert_not link.valid?
    assert_includes link.errors[:slug], "is reserved"
  end

  test "slug rejects invalid characters" do
    link = @user.links.build(original_url: "https://example.com", slug: "bad slug!")
    assert_not link.valid?
    assert link.errors[:slug].any?
  end

  test "original_url must be present" do
    link = @user.links.build(slug: "nope")
    assert_not link.valid?
    assert_includes link.errors[:original_url], "can't be blank"
  end

  test "original_url must be http or https" do
    link = @user.links.build(original_url: "ftp://bad.example.com", slug: "ftp1")
    assert_not link.valid?
    assert link.errors[:original_url].any?
  end

  test "expired? returns false when no expires_at" do
    assert_not links(:active_link).expired?
  end

  test "expired? returns true when expires_at is past" do
    assert links(:expired_link).expired?
  end

  test "expired? returns true when clicks_count >= max_clicks" do
    link = links(:active_link)
    link.max_clicks = link.clicks_count
    assert link.expired?
  end

  test "password_protected? is false when no password set" do
    assert_not links(:active_link).password_protected?
  end

  test "password_protected? is true when password digest present" do
    assert links(:password_link).password_protected?
  end

  test "same slug allowed on different custom domains" do
    domain_a = custom_domains(:example_domain)
    domain_b = custom_domains(:unverified_domain)

    @user.links.create!(original_url: "https://a.com", slug: "sameslug", custom_domain: domain_a)
    link_b = @user.links.build(original_url: "https://b.com", slug: "sameslug", custom_domain: domain_b)
    assert link_b.valid?
  end

  test "same slug allowed on custom domain and default domain" do
    domain = custom_domains(:example_domain)
    @user.links.create!(original_url: "https://a.com", slug: "dualslug", custom_domain: domain)
    link_default = @user.links.build(original_url: "https://b.com", slug: "dualslug")
    assert link_default.valid?
  end

  test "duplicate slug rejected on same custom domain" do
    domain = custom_domains(:example_domain)
    @user.links.create!(original_url: "https://a.com", slug: "dup", custom_domain: domain)
    dup = @user.links.build(original_url: "https://b.com", slug: "dup", custom_domain: domain)
    assert_not dup.valid?
    assert_includes dup.errors[:slug], "has already been taken"
  end

  test "archived links excluded from uniqueness check" do
    # archived_link fixture has slug "oldlink" and archived: true
    new_link = @user.links.build(original_url: "https://new.com", slug: "oldlink")
    assert new_link.valid?
  end

  test "not_archived scope excludes archived links" do
    assert_includes Link.not_archived, links(:active_link)
    assert_not_includes Link.not_archived, links(:archived_link)
  end

  test "archived scope includes only archived links" do
    assert_includes Link.archived, links(:archived_link)
    assert_not_includes Link.archived, links(:active_link)
  end

  test "domain_label returns custom domain name or slsh.me" do
    assert_equal "links.example.com", links(:custom_domain_link).domain_label
    assert_equal "slsh.me", links(:active_link).domain_label
  end

  test "short_url uses /l/ prefix for default domain links" do
    link = links(:active_link)
    assert_equal "https://slsh.me/l/#{link.slug}", link.short_url
  end

  test "short_url uses root path for custom domain links" do
    link = links(:custom_domain_link)
    assert_equal "https://links.example.com/#{link.slug}", link.short_url
  end
end
