defmodule SeshonWeb.FriendshipsWidget do
  @moduledoc """
  Reusable friendship search + action widget that can render inline or in the header.
  """
  use SeshonWeb, :live_component

  alias Seshon.Friendships

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:results, fn -> [] end)
      |> assign_new(:search, fn -> "" end)
      |> assign_new(:notice, fn -> nil end)
      |> assign_new(:mode, fn -> :panel end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class={section_classes(@mode)}>
      <div class="flex items-center justify-between gap-4">
        <h3 class="text-base font-semibold">Find friends</h3>
        <button
          :if={@notice}
          class="text-xs text-base-content/70"
          phx-target={@myself}
          phx-click="dismiss_notice"
        >
          Clear
        </button>
      </div>

      <p :if={@notice} class={notice_classes(@notice)}>
        {elem(@notice, 1)}
      </p>

      <form phx-target={@myself} phx-change="search" phx-debounce="300" class="mb-4">
        <label class="input">
          <svg class="h-[1em] opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <g
              stroke-linejoin="round"
              stroke-linecap="round"
              stroke-width="2.5"
              fill="none"
              stroke="currentColor"
            >
              <circle cx="11" cy="11" r="8"></circle>
              <path d="m21 21-4.3-4.3"></path>
            </g>
          </svg>
          <input type="search" class="grow" placeholder="Search" name="query" value={@search} />
        </label>
      </form>

      <p :if={@results == [] && @search == ""} class="text-sm text-base-content/70">
        Start typing to search for people you can add.
      </p>

      <p :if={@results == [] && @search != ""} class="text-sm text-base-content/70">
        No users found for "{@search}".
      </p>

      <ul :if={@results != []} class="list bg-base-100 rounded-box shadow-sm divide-y divide-base-200">
        <li :for={result <- @results} class="p-3 text-sm">
          <div class="flex items-center justify-between gap-3">
            <div class="flex items-center gap-3">
              <div class="avatar w-10 h-10 rounded-full bg-base-300 flex items-center justify-center text-base font-semibold">
                <%= if has_thumbnail?(result) do %>
                  <img
                    src={result.user.thumbnail}
                    alt={result.user.first_name}
                    class="w-full h-full object-cover rounded-full"
                  />
                <% else %>
                  {get_user_initials(result.user)}
                <% end %>
              </div>
              <div>
                <p class="font-medium">
                  {result.user.first_name} {result.user.last_name}
                </p>
                <p class="text-xs text-base-content/70">{result.user.email}</p>
              </div>
            </div>
            <.friend_request_button
              status={result.accepted}
              user={result.user}
              friendship_id={result.friendship_id}
              is_sender={result.is_sender}
              is_receiver={result.is_receiver}
              target={@myself}
            />
          </div>
        </li>
      </ul>
    </section>
    """
  end

  @impl true
  def handle_event("dismiss_notice", _params, socket) do
    {:noreply, assign(socket, :notice, nil)}
  end

  def handle_event("search", %{"query" => query}, socket) do
    results =
      Friendships.search_users_with_friendships_by_name(
        query,
        socket.assigns.current_scope.user.id
      )

    {:noreply, socket |> assign(search: query, results: results) |> assign(:notice, nil)}
  end

  def handle_event("request_friendship", %{"user_id" => user_id}, socket) do
    response = Friendships.request_friendship(socket.assigns.current_scope, user_id)
    handle_friend_result(response, socket, "Friendship request sent")
  end

  def handle_event("accept_friendship", %{"friendship_id" => friendship_id}, socket) do
    response = Friendships.accept_friendship(socket.assigns.current_scope, friendship_id)
    handle_friend_result(response, socket, "Friendship accepted")
  end

  def handle_event("delete_friendship", %{"friendship_id" => friendship_id}, socket) do
    response = Friendships.remove_friendship(socket.assigns.current_scope, friendship_id)
    handle_friend_result(response, socket, "Friend removed")
  end

  defp handle_friend_result({:ok, _}, socket, message) do
    {:noreply, socket |> assign(:notice, {:info, message}) |> refresh_results()}
  end

  defp handle_friend_result({:error, reason}, socket, _message) do
    {:noreply, assign(socket, :notice, {:error, friendly_error(reason)})}
  end

  defp refresh_results(%{assigns: %{search: search}} = socket) do
    if search == "" do
      assign(socket, :results, [])
    else
      results =
        Friendships.search_users_with_friendships_by_name(
          search,
          socket.assigns.current_scope.user.id
        )

      assign(socket, :results, results)
    end
  end

  defp friendly_error(:friendship_already_exists), do: "Already friends or pending"
  defp friendly_error(:unauthorized), do: "Action not allowed"
  defp friendly_error(:not_found), do: "Friendship not found"
  defp friendly_error(_), do: "Something went wrong"

  defp section_classes(:page), do: "space-y-4"

  defp section_classes(_panel) do
    "space-y-4 text-sm"
  end

  defp notice_classes({:info, _}) do
    "text-xs text-success"
  end

  defp notice_classes({:error, _}) do
    "text-xs text-error"
  end

  defp notice_classes(_), do: "text-xs"

  defp has_thumbnail?(result) do
    result.user.thumbnail && result.user.thumbnail != "" && result.user.thumbnail != nil
  end

  defp get_user_initials(user) do
    first_initial = String.first(user.first_name || "")
    last_initial = String.first(user.last_name || "")
    "#{first_initial}#{last_initial}" |> String.upcase()
  end

  attr :status, :any, required: true
  attr :user, :map, required: true
  attr :friendship_id, :any
  attr :is_sender, :boolean
  attr :is_receiver, :boolean
  attr :target, :any, required: true

  def friend_request_button(assigns) do
    {label, classes, disabled, event, value} =
      get_button_props(
        assigns.status,
        assigns.user,
        assigns.friendship_id,
        assigns.is_sender,
        assigns.is_receiver
      )

    assigns = assign(assigns, :button_props, {label, classes, disabled, event, value})

    ~H"""
    <button
      class={elem(@button_props, 1)}
      disabled={elem(@button_props, 2)}
      phx-target={@target}
      {event_attrs(@button_props, @friendship_id)}
    >
      {elem(@button_props, 0)}
    </button>
    """
  end

  defp event_attrs({_, _, _, nil, _}, _friendship_id), do: []

  defp event_attrs({_, _, _, event, user_id}, friendship_id) when not is_nil(user_id) do
    [
      {"phx-click", event},
      {"phx-value-user_id", user_id},
      {"phx-value-friendship_id", friendship_id}
    ]
  end

  defp event_attrs({_, _, _, event, _value}, friendship_id) do
    [
      {"phx-click", event},
      {"phx-value-friendship_id", friendship_id}
    ]
  end

  defp get_button_props(true, _user, friendship_id, _is_sender, _is_receiver) do
    {"Delete", "btn btn-soft btn-success text-xs", false, "delete_friendship", friendship_id}
  end

  defp get_button_props(nil, user, _friendship_id, _is_sender, _is_receiver) do
    {"Request", "btn btn-soft btn-primary text-xs", false, "request_friendship", user.id}
  end

  defp get_button_props(false, _user, friendship_id, false, true) do
    {"Accept", "btn btn-soft btn-success text-xs", false, "accept_friendship", friendship_id}
  end

  defp get_button_props(_status, _user, _friendship_id, _is_sender, _is_receiver) do
    {"Pending", "btn btn-soft btn-info text-xs", true, nil, nil}
  end
end
