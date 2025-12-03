# frozen_string_literal: true

RSpec.describe "Topic List Tooltips", type: :system do
  let!(:theme) { upload_theme_component }

  fab!(:topic_with_excerpt) do
    topic = Fabricate(:topic, title: "Topic with excerpt")
    Fabricate(:post, topic: topic, raw: "This is a topic excerpt with content")
    topic.update!(excerpt: "This is a topic excerpt with content")
    topic
  end

  fab!(:topic_without_excerpt) do
    topic = Fabricate(:topic, title: "Topic without excerpt")
    Fabricate(:post, topic: topic, raw: "Short topic content here")
    topic.update!(excerpt: nil)
    topic
  end
  
  fab!(:user)

  before do
    theme.theme_modifier_set.serialize_topic_excerpts = true
    theme.theme_modifier_set.save!

    # Ensure user uses the default theme (which includes our component)
    user.user_option.update!(theme_ids: [SiteSetting.default_theme_id])
    sign_in(user)
  end

  context "with excerpt mode" do
    it "displays tooltip with excerpt on hover" do
      visit("/latest")

      # Wait for the tooltip trigger to be present (component loaded)
      expect(page).to have_css(".topic-list-item[data-topic-id='#{topic_with_excerpt.id}'] .fk-d-tooltip__trigger", wait: 5)

      link = find(".topic-list-item[data-topic-id='#{topic_with_excerpt.id}'] .fk-d-tooltip__trigger")
      link.hover

      expect(page).to have_css(".fk-d-tooltip__content", text: "This is a topic excerpt", wait: 5)
    end

    it "does not display tooltip for topics without excerpts" do
      visit("/latest")

      link = find(".topic-list-item[data-topic-id='#{topic_without_excerpt.id}'] .main-link")
      link.hover

      expect(page).to have_no_css(".fk-d-tooltip__content")
    end
  end

  context "with gist mode" do
    it "updates the setting" do
      theme.update_setting(:tooltip_content, "ai_topic_gist")
      theme.save!

      expect(theme.cached_settings[:tooltip_content]).to eq("ai_topic_gist")
    end
  end
end
