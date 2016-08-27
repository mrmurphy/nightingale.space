defmodule Nightingale.TweetsChannel do
  use Nightingale.Web, :channel
  def join("tweets:lobby", payload, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  def broadcast_tweet(tweet) do
    Nightingale.Endpoint.broadcast("tweets:lobby", "tweet", tweet)
  end
end
