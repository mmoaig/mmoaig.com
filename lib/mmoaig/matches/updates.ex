defmodule Mmoaig.Matches.Updates do
  @topic "match-updates"
  @pubsub Mmoaig.PubSub

  def broadcast(match) do
    Phoenix.PubSub.broadcast(@pubsub, topic_for_match(match.id), {:match_updated, match})
  end

  def subscribe(match_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic_for_match(match_id))
  end

  defp topic_for_match(match_id), do: "#{@topic}:#{match_id}"
end
