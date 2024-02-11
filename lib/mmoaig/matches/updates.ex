defmodule Mmoaig.Matches.Updates do
  @topic "match-updates"
  @pubsub Mmoaig.PubSub

  alias Mmoaig.Matches
  alias Mmoaig.Matches.Match

  def broadcast_match(%Match{} = match) do
    Phoenix.PubSub.broadcast(@pubsub, topic_for_match(match.id), {:match_updated, match})
  end

  def broadcast_log_messages(match_id) do
    log_messages = Matches.list_log_messages(match_id)

    Phoenix.PubSub.broadcast(
      @pubsub,
      topic_for_match(match_id),
      {:log_messages_updated, log_messages}
    )
  end

  def subscribe(match_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic_for_match(match_id))
  end

  defp topic_for_match(match_id), do: "#{@topic}:#{match_id}"
end
