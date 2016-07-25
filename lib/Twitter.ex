defmodule Twitter do
  def reader(dest) do
    fn ->
      topics = "#ngale"
      stream = ExTwitter.stream_filter(track: topics, timeout: :infinity)
        |> Stream.map(fn x ->
          %{:text => x.text, :author => x.user.name, :pic => x.user.profile_image_url} end)
        |> Stream.each(fn x -> send dest, {:tweet, x} end)
      Enum.to_list(stream)
    end
  end

  def listener(callback) do
    spawn reader(self)
    receive do
      {:tweet, msg} -> Kernel.apply(callback, [msg])
      IO.puts "Got tweet: " <> msg.text
      :timer.sleep 2500
      listener(callback)
    end
  end
end
