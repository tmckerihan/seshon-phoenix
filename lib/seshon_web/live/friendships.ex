defmodule SeshonWeb.Friendships do
  use SeshonWeb, :live_view

  alias Seshon.Friendships

  defp get_user_initials(user) do
    first_initial = String.first(user.first_name || "")
    last_initial = String.first(user.last_name || "")
    "#{first_initial}#{last_initial}" |> String.upcase()
  end

  defp has_thumbnail?(result) do
    result.user.thumbnail && result.user.thumbnail != "" && result.user.thumbnail != nil
  end

  defp friend_request_button(assigns) do
    {button_text, button_class, disabled, phx_click, phx_value} =
      get_button_props(
        assigns.status,
        assigns.user,
        assigns.friendship_id,
        assigns.is_sender,
        assigns.is_receiver
      )

    ~H"""
    <button
      class={button_class}
      disabled={disabled}
      phx-click={phx_click}
      phx-value-user_id={phx_value}
      phx-value-friendship_id={assigns.friendship_id}
    >
      {button_text}
    </button>
    """
  end

  defp get_button_props(true, _user, _friendship_id, _is_sender, _is_receiver) do
    {"Friends", "btn btn-soft btn-success", true, nil, nil}
  end

  defp get_button_props(nil, user, _friendship_id, _is_sender, _is_receiver) do
    {"Request", "btn btn-soft btn-primary", false, "request_friendship", user.id}
  end

  defp get_button_props(false, _user, friendship_id, false, true) do
    {"Accept", "btn btn-soft btn-success", false, "accept_friendship", friendship_id}
  end

  defp get_button_props(_status, _user, _friendship_id, _is_sender, _is_receiver) do
    {"Pending", "btn btn-soft btn-info", true, nil, nil}
  end

  def render(assigns) do
    ~H"""
    <.header>
      Friendships
    </.header>
    <form phx-change="search" phx-debounce="300" class="mb-4">
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
        <input type="search" class="grow" placeholder="Search" name="query" />
      </label>
    </form>
    <ul class="list bg-base-100 rounded-box shadow-md max-w-lg">
      <%= for result <- @results do %>
        <li class="p-4 pb-2 text-xs opacity-60 tracking-wide">
          <div class="flex items-center justify-between w-full">
            <div class="flex items-center">
              <div class="avatar-2 w-[45px] h-[45px] rounded-full mr-4 flex items-center justify-center text-[#F8F6F2] font-bold text-[1.2rem] bg-cover bg-center border-2 border-[#FFFFFF] ring-1 ring-[#E0DCD5]">
                <%= if has_thumbnail?(result) do %>
                  <img
                    src={result.user.thumbnail}
                    alt={result.user.first_name}
                    class="w-full h-full object-cover rounded-full"
                  />
                <% else %>
                  <div class="w-full h-full rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold">
                    {get_user_initials(result.user)}
                  </div>
                <% end %>
              </div>
              <div>{result.user.first_name} {result.user.last_name}</div>
            </div>
            <.friend_request_button
              status={result.accepted}
              user={result.user}
              friendship_id={result.friendship_id}
              is_sender={result.is_sender}
              is_receiver={result.is_receiver}
            />
          </div>
        </li>
      <% end %>
    </ul>
    """
  end

  def mount(_params, _session, socket) do
    # Subscribe to friendship updates for the current user
    Friendships.subscribe_friendships(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:results, [])
     |> assign(:search, "")}
  end

  @spec handle_event(<<_::48>>, map(), any()) :: {:noreply, any()}
  def handle_event("search", %{"query" => query}, socket) do
    current_user = socket.assigns.current_scope.user
    search_results = Friendships.search_users_with_friendships_by_name(query, current_user.id)

    {:noreply,
     socket
     |> assign(search: query)
     |> assign(results: search_results)}
  end

  def handle_event("request_friendship", %{"user_id" => user_id}, socket) do
    case Friendships.request_friendship(socket.assigns.current_scope, user_id) do
      {:ok, _} ->
        {:noreply, socket |> put_flash(:info, "Friendship request sent")}

      {:error, :friendship_already_exists} ->
        {:noreply, socket |> put_flash(:error, "Friendship already exists")}
    end
  end

  # Handle PubSub messages for friendship updates
  def handle_info({:created, friendship}, socket) do
    # Update the specific user's friendship status in results
    updated_results = update_friendship_status(socket.assigns.results, friendship)

    {:noreply, assign(socket, :results, updated_results)}
  end

  def handle_info({:updated, friendship}, socket) do
    # Update the specific user's friendship status in results
    updated_results = update_friendship_status(socket.assigns.results, friendship)

    {:noreply, assign(socket, :results, updated_results)}
  end

  def handle_info({:deleted, friendship}, socket) do
    # Update the specific user's friendship status in results
    updated_results = update_friendship_status(socket.assigns.results, friendship)

    {:noreply, assign(socket, :results, updated_results)}
  end

  # Helper to update friendship status for a specific user
  defp update_friendship_status(results, friendship) do
    Enum.map(results, fn result ->
      user_id = result.user.id

      cond do
        # If this friendship involves the current user and the result user
        friendship.user_1 == user_id or friendship.user_2 == user_id ->
          %{result | accepted: friendship.accepted}

        # Otherwise, keep the result unchanged
        true ->
          result
      end
    end)
  end
end
