defmodule Twitter do
  def reader(dest) do
    fn ->
      topics = "nightingalespc,elmconf"
      stream = ExTwitter.stream_filter(track: topics, timeout: :infinity)
        |> Stream.map(fn x ->
          %{:text => x.text, :author => x.user.name, :pic => x.user.profile_image_url} end)
        |> Stream.each(fn x -> send dest, {:tweet, x} end)
      Enum.to_list(stream)
    end
  end

  def listener(callback, readerPID) do
    readerPID = case readerPID do
      Nil -> spawn reader(self)
      other -> other
    end
    receive do
      {:tweet, msg} -> Kernel.apply(callback, [msg])
      IO.puts "Got tweet: " <> msg.text
      :timer.sleep 500
      listener(callback, readerPID)
    end
  end
end
