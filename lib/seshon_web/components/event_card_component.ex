defmodule SeshonWeb.EventCardComponent do
  use SeshonWeb, :html

  def event_card(assigns) do
    ~H"""
    <a href={~p"/events/#{@event.event}"} class="hover:bg-gray-100 flex-grow">
      <article
        class="bg-[#FFFFFF] rounded-[12px] mb-6 p-6 border border-[#E0DCD5] shadow-[0_4px_10px_rgba(0,0,0,0.06)] transition-transform transition-shadow duration-200 ease-in-out hover:shadow-[0_6px_15px_rgba(0,0,0,0.08)] hover:-translate-y-1"
        style="animation: fadeInSlideUp var(--animation-speed-fast) ease-out forwards; animation-delay: var(--animation-speed-stagger);"
      >
        <div class="flex items-center mb-2">
          <div class="avatar-2 w-[45px] h-[45px] rounded-full mr-4 flex items-center justify-center text-[#F8F6F2] font-bold text-[1.2rem] bg-cover bg-center border-2 border-[#FFFFFF] ring-1 ring-[#E0DCD5]">
          </div>
          <div>
            <div class="font-semibold text-[#333333]">{@event.owner_name}</div>
            <div class="text-[0.85rem] text-[#A0A0A0]">
              {Calendar.strftime(@event.event.date, "%B %d, %Y at %I:%M %p")}
            </div>
          </div>
        </div>
        <div>
          <div class="flex items-center mb-[0.7rem]">
            <div class="w-[45px] h-[45px] mr-3 flex items-center justify-center text-[1.8rem] shrink-0">
              {@event.event.icon}
            </div>
            <h3
              class="text-[1.3rem] font-bold text-[#2E4638]"
              style="font-family: var(--font-secondary);"
            >
              {@event.event.title}
            </h3>
          </div>
          <div class="text-[0.95rem] text-[#587464] mb-[1.2rem] flex flex-wrap gap-x-6 gap-y-[0.6rem] ml-3">
          </div>
          <p class="text-base text-[#333333] mb-6 leading-relaxed">
            {@event.event.description}
          </p>
        </div>
        <div class="flex justify-start items-center border-t border-[#E0DCD5] pt-[1.2rem]">
          <%= if !@event.is_owner do %>
            <.event_response event={@event.event} owner_name={@event.owner_name} />
          <% end %>
        </div>
      </article>
    </a>
    """
  end

  def event_response(assigns) do
    assigns =
      assigns
      |> assign_new(:owner_name, fn -> nil end)
      |> assign_new(:response_options, &default_response_options/0)

    ~H"""
    <section class="w-full">
      <div class="w-full rounded-2xl border border-base-200 bg-base-100/80 p-4">
        <div class="flex flex-col gap-2 sm:flex-row sm:items-stretch">
          <button
            :for={option <- @response_options}
            type="button"
            class={[
              "btn btn-sm sm:btn-md btn-outline grow justify-start gap-3 rounded-2xl border-base-300 bg-base-100 text-left transition hover:border-base-content/40 hover:bg-base-200",
              option.class
            ]}
            data-response={option.id}
          >
            <div class="flex h-9 w-9 items-center justify-center rounded-xl bg-base-200 text-base-content/80">
              <.icon name={option.icon} class="h-5 w-5" />
            </div>
            <div class="flex flex-col leading-tight">
              <span class="text-sm font-semibold">{option.label}</span>
              <span :if={option.description} class="text-xs text-base-content/60">
                {option.description}
              </span>
            </div>
          </button>
        </div>
      </div>
    </section>
    """
  end

  defp default_response_options do
    [
      %{
        id: "going",
        label: "Going",
        description: "Count me in",
        icon: "hero-hand-thumb-up",
        class: "hover:border-primary hover:text-primary"
      },
      %{
        id: "maybe",
        label: "Maybe",
        description: "Depends how the day goes",
        icon: "hero-sparkles",
        class: "hover:border-secondary hover:text-secondary"
      },
      %{
        id: "decline",
        label: "Not going",
        description: "Catch y'all next time",
        icon: "hero-hand-thumb-down",
        class: "hover:border-error hover:text-error"
      }
    ]
  end
end
