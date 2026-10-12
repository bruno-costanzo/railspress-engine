# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin sidebar credit", type: :system do
  it "underlines its link so it is not told apart by color alone" do
    visit railspress.admin_root_path

    decoration = page.evaluate_script("getComputedStyle(document.querySelector('.rp-sidebar-credit-link')).textDecorationLine")

    expect(decoration).to eq("underline")
  end
end
