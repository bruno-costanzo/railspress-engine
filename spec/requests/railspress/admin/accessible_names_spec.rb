# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin form controls have accessible names", type: :request do
  fixtures "users", "railspress/categories", "railspress/posts"

  before do
    admin_id = users(:api_admin).id
    Railspress.configure do |config|
      config.enable_post_images
      config.enable_api
      config.current_admin_proc = -> { User.find_by(id: admin_id) }
      config.register_entity :project
    end
  end

  def unnamed_controls
    document = Nokogiri::HTML(response.body)
    controls = document.css("input:not([type=hidden]):not([type=submit]):not([type=button]), select, textarea")

    controls.reject { |control| named?(document, control) }.map { |control| control.to_html[/\A<[^>]*>/] }
  end

  def named?(document, control)
    return true if control["aria-label"].present? || control["title"].present?
    return true if control["placeholder"].present? && control.name != "select"
    return true if control["aria-labelledby"].to_s.split.any? { |id| document.at_css("##{id}")&.text.present? }
    return true if control.ancestors("label").any?

    control["id"].present? && document.css("label").any? { |label| label["for"] == control["id"] }
  end

  {
    "the post list" => -> { railspress.admin_posts_path },
    "the new post form" => -> { railspress.new_admin_post_path },
    "the new entity form" => -> { railspress.admin_new_entity_path(entity_type: "projects") },
    "the Agents & API page" => -> { railspress.admin_api_keys_path }
  }.each do |page, path|
    it "names every form control on #{page}" do
      get instance_exec(&path)

      expect(response).to have_http_status(:ok)
      expect(unnamed_controls).to be_empty
    end
  end
end
