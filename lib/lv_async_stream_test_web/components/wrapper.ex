defmodule AsyncStreamTestWeb.Wrapper do
  @moduledoc """

  """
  use Phoenix.Component

  slot :tab, required: true

  def render(assigns) do
    ~H"""
    <!-- Error with stream only occurs when enum'ing through slot -->
    <div :for={{tab, _i} <- Enum.with_index(@tab)}>
      <%= render_slot(tab) %>
    </div>
    """
  end
end
