# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin pages under a nonce-based Content Security Policy", type: :request do
  fixtures "railspress/categories", "railspress/posts", "railspress/content_groups", "railspress/content_elements"

  def script_nonce
    response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
  end

  def inline_scripts
    Nokogiri::HTML(response.body).css("script:not([src])")
  end

  def inline_event_handlers
    Nokogiri::HTML(response.body).xpath("//@*[starts-with(name(), 'on')]").map { |attribute| "#{attribute.parent.name}[#{attribute.name}]" }
  end

  def header_image_post
    railspress_posts(:hello_world).tap do |post|
      post.header_image.attach(
        io: File.open(Rails.root.join("../../spec/fixtures/files/test_image.png")),
        filename: "test_image.png",
        content_type: "image/png"
      )
      post.header_image_focal_point
      post.save!
    end
  end

  context "with a policy" do
    include_context "with a nonce-based content security policy"

    {
      "the post form" => -> { railspress.edit_admin_post_path(railspress_posts(:hello_world)) },
      "the post import page" => -> { railspress.typed_admin_imports_path(type: "posts") },
      "the CMS transfer page" => -> { railspress.admin_cms_transfer_path },
      "the content elements list" => -> { railspress.admin_content_elements_path },
      "the image editor" => -> { railspress.image_editor_admin_post_path(header_image_post, attachment: :header_image) }
    }.each do |page, path|
      it "gives every inline script on #{page} the request's nonce" do
        get instance_exec(&path)

        expect(response).to have_http_status(:ok)
        expect(inline_scripts.map { |script| script["nonce"] }).to all(eq(script_nonce))
      end

      it "has no inline event handler attributes on #{page}" do
        get instance_exec(&path)

        expect(inline_event_handlers).to be_empty
      end
    end
  end

  context "without a policy" do
    it "renders the layout's module import without a nonce attribute" do
      get railspress.admin_posts_path

      import = inline_scripts.find { |script| script.text == %(import "railspress") }
      expect(import).to be_present
      expect(import["nonce"]).to be_nil
    end
  end
end
