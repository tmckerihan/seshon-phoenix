defmodule SeshonWeb.LiveLayouts do
  use SeshonWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      {@inner_content}
    </div>
    """
  end
end
