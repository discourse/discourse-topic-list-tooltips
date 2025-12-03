import TopicListTooltip from "../../components/topic-list-tooltip";

<template>
  <TopicListTooltip @topic={{@outletArgs.topic}}>
    {{yield}}
  </TopicListTooltip>
</template>
