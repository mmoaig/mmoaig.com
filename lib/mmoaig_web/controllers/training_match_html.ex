defmodule MmoaigWeb.TrainingMatchHTML do
  use MmoaigWeb, :html

  embed_templates "training_match_html/*"

  def training_partner_options(training_partners) do
    Enum.map(training_partners, &training_partner_option/1)
  end

  defp training_partner_option(training_partner) do
    {training_partner.name, training_partner.id}
  end
end
