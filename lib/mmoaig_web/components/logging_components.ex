defmodule MmoaigWeb.LoggingComponents do
  use Phoenix.Component

  alias Mmoaig.Matches.LogMessage

  attr :log_message, LogMessage, required: true

  def log_message(%{log_message: %LogMessage{level: "log"}} = assigns) do
    ~H"""
    <div class="text-sm font-medium flex py-2 justify-between pl-8 text-white">
      <p class="pr-20"><%= assigns.log_message.message %></p>
      <time class="whitespace-nowrap"><%= assigns.log_message.inserted_at %></time>
    </div>
    """
  end

  def log_message(%{log_message: %LogMessage{level: "info"}} = assigns) do
    ~H"""
    <div class="flex py-2">
      <div class="flex-shrink-0">
        <svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
      <.message_content log_message={@log_message} color="blue" />
    </div>
    """
  end

  def log_message(%{log_message: %LogMessage{level: "warning"}} = assigns) do
    ~H"""
    <div class="flex py-2">
      <div class="flex-shrink-0">
        <svg
          class="h-5 w-5 text-yellow-400"
          viewBox="0 0 20 20"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            fill-rule="evenodd"
            d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
      <.message_content log_message={@log_message} color="yellow" />
    </div>
    """
  end

  def log_message(%{log_message: %LogMessage{level: "error"}} = assigns) do
    ~H"""
    <div class="flex py-2">
      <div class="flex-shrink-0">
        <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z"
            clip-rule="evenodd"
          />
        </svg>
      </div>
      <.message_content log_message={@log_message} color="red" />
    </div>
    """
  end

  defp message_content(assigns) do
    ~H"""
    <div class={"grow flex justify-between text-sm font-medium ml-3 text-#{@color}-300"}>
      <p class="pr-20"><%= @log_message.message %></p>
      <time class="whitespace-nowrap"><%= @log_message.inserted_at %></time>
    </div>
    """
  end
end
