import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import { htmlSafe } from "@ember/template";
import replaceEmoji from "discourse/helpers/replace-emoji";
import DTooltip from "float-kit/components/d-tooltip";

const triggers = {
  mobile: ["hover"],
  desktop: ["hover"],
};

let TABLE_AI_LAYOUT = "table-ai";
import("discourse/plugins/discourse-ai/discourse/services/gists")
  .then((module) => {
    TABLE_AI_LAYOUT = module.TABLE_AI_LAYOUT;
  })
  .catch(() => {
    // use fallback
  });

export default class TopicListTooltip extends Component {
  get gistsService() {
    try {
      return getOwner(this).lookup("service:gists");
    } catch {
      return null;
    }
  }

  get gistsPreference() {
    return this.gistsService?.currentPreference ?? null;
  }

  get isGistModeActive() {
    return this.gistsPreference === TABLE_AI_LAYOUT;
  }

  get shouldShowGistTooltip() {
    return (
      settings.tooltip_content === "ai_topic_gist" &&
      this.args.topic.ai_topic_gist &&
      !this.isGistModeActive
    );
  }

  get shouldShowExcerptTooltip() {
    return (
      settings.tooltip_content === "first_post_excerpt" &&
      this.args.topic.excerpt &&
      !this.isGistModeActive
    );
  }

  get shouldShowTooltip() {
    return this.shouldShowGistTooltip || this.shouldShowExcerptTooltip;
  }

  get tooltipContent() {
    if (this.shouldShowGistTooltip) {
      return this.args.topic.ai_topic_gist;
    }
    if (this.shouldShowExcerptTooltip) {
      return replaceEmoji(htmlSafe(this.args.topic.excerpt));
    }
    return null;
  }

  <template>
    {{#if this.shouldShowTooltip}}
      <DTooltip
        @triggers={{triggers}}
        @untriggers={{triggers}}
        @placement="bottom-start"
      >
        <:trigger>
          {{yield}}
        </:trigger>
        <:content>
          <div class="d-tooltip-content">
            {{this.tooltipContent}}
          </div>
        </:content>
      </DTooltip>
    {{else}}
      {{yield}}
    {{/if}}
  </template>
}
