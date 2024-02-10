defmodule MmoaigWeb.LoggingComponents do
  use Phoenix.Component

  alias Mmoaig.Matches.LogMessage

  attr :log_message, LogMessage, required: true

  def log_message(%{log_message: %LogMessage{level: "log"}} = assigns) do
    ~H"""
    <div class="text-sm font-medium flex py-2 justify-between ml-8 text-white">
      <p><%= assigns.log_message.message %></p>
      <time><%= assigns.log_message.inserted_at %></time>
    </div>
    """
  end
end
