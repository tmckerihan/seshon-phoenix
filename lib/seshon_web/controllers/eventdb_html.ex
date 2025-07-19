defmodule SeshonWeb.EventDbHTML do
  use SeshonWeb, :html

  embed_templates "eventdb_html/*"

  @doc """
  Renders a event form.

  The form is defined in the template at
  event_html/event_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def event_form(assigns)
end
