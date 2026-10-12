# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin under a nonce-based Content Security Policy", type: :system do
  include_context "with a nonce-based content security policy"

  fixtures "railspress/categories", "railspress/posts", "railspress/content_groups", "railspress/content_elements"

  let(:files) { Rails.root.join("../../spec/fixtures/files") }

  it "enables the post import once a file is chosen" do
    visit railspress.typed_admin_imports_path(type: "posts")
    expect(page).to have_button("Start Import", disabled: true)

    attach_file "import_file", files.join("valid_post.md"), make_visible: true

    expect(page).to have_css("#file-list .rp-file-name", text: "valid_post.md")
    expect(page).to have_button("Start Import", disabled: false)
  end

  it "enables the CMS import once a file is chosen" do
    visit railspress.admin_cms_transfer_path
    expect(page).to have_button("Import", exact: true, disabled: true)

    attach_file "cms_import_file", files.join("posts_import.zip"), make_visible: true

    expect(page).to have_css("#cms-file-info", text: "posts_import.zip")
    expect(page).to have_button("Import", exact: true, disabled: false)
  end

  it "fills the calculated reading time" do
    post = railspress_posts(:hello_world)
    visit railspress.edit_admin_post_path(post)

    fill_in "Reading Time (min)", with: ""
    click_button "Calculate"

    expect(page).to have_field("Reading Time (min)", with: post.calculate_reading_time.to_s)
  end

  it "filters content elements as soon as a group is chosen" do
    group = railspress_content_groups(:headers)
    visit railspress.admin_content_elements_path

    select group.name, from: "Filter by group:"

    expect(page).to have_current_path(/content_group_id=#{group.id}/)
  end

  it "removes an image from the image editor after confirmation" do
    Railspress.configure do |config|
      config.enable_post_images
      config.enable_focal_points
    end
    post = railspress_posts(:hello_world)
    post.header_image.attach(io: File.open(files.join("test_image.png")), filename: "test_image.png", content_type: "image/png")
    visit railspress.edit_admin_post_path(post)

    find(".rp-image-section__overlay a", visible: :all).click
    accept_confirm("Remove this image?") { click_button "Remove" }

    expect(page).to have_text("Image removed")
    expect(post.reload.header_image).not_to be_attached
  end
end
