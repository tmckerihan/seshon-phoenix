defmodule Seshon.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Seshon.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        date: ~U[2025-07-12 22:38:00Z],
        description: "some description",
        icon: "some icon",
        location: "some location",
        title: "some title"
      })

    {:ok, event} = Seshon.Events.create_event(scope, attrs)
    event
  end
end
