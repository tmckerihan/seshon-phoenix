defmodule SeshonWeb.Hooks.Friendships do
  use SeshonWeb, :live_view

  def on_mount(:inject_friendship_results, _params, _session, socket) do
    {:cont, assign(socket, :friendship_results, [])}
  end
end
