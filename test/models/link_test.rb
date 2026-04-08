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
end
