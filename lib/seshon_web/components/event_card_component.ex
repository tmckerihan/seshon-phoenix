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
        <div class="flex justify-between items-center border-t border-[#E0DCD5] pt-[1.2rem]">
          <div class="flex justify-between items-center"></div>
        </div>
      </article>
    </a>
    """
  end
end
