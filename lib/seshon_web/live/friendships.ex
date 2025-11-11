defmodule SeshonWeb.Friendships do
  use SeshonWeb, :live_view

  alias SeshonWeb.FriendshipsWidget

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Friendships
      </.header>

      <.live_component
        module={FriendshipsWidget}
        id="friendships-page"
        current_scope={@current_scope}
        mode={:page}
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
