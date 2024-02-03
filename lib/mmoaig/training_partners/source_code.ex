defmodule Mmoaig.TrainingPartners.SourceCode do
  alias Mmoaig.TrainingPartners.Registration

  @finch Mmoaig.Finch

  def fetch_source_code_for_registration!(%Registration{
        repository_url: repository_url,
        entry_point: entry_point
      }) do
    :get
    |> Finch.build("#{repository_url}#{entry_point}")
    |> Finch.request!(@finch)
    |> ensure_successful_fetch()
    |> Map.get(:body)
  end

  defp ensure_successful_fetch(response) do
    case response.status do
      200 ->
        response

      _ ->
        raise "Could not fetch source code for registration. Got status #{response.status}"
    end
  end
end
