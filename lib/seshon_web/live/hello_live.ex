defmodule SeshonWeb.HelloLive do
  @moduledoc """
  Minimal LiveView that demonstrates using the shared header/layout.
  """
  use SeshonWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Hello")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app socket={@socket} flash={@flash} current_scope={@current_scope}>
      <.header>
        Greetings
        <:subtitle>A LiveView page automatically wrapped in the shared header layout.</:subtitle>
      </.header>

      <p class="text-lg">
        Hello from LiveView! Because this route opts into the `SeshonWeb.Layouts.app/1` layout,
        the header/nav and flash handling render once around all page content.
      </p>
      {@friendship_results}
    </Layouts.app>
    """
  end
end
