defmodule Hello.Documents.LandingPage.LandingPageSection do
  use Ecto.Schema
  use InstructorLite.Instruction

  @section_types [
    :hero,
    :features,
    :benefits,
    :how_it_works,
    :testimonials,
    :pricing,
    :comparison,
    :faq,
    :about_us,
    :cta_primary,
    :contact_form,
    :footer
  ]

  @primary_key false
  embedded_schema do
    field(:section_type, Ecto.Enum, values: @section_types)
    field(:headline, :string)
    field(:subheadline, :string)
    field(:content, :string)
    field(:cta_text, :string)
  end
end

defmodule Hello.Documents.LandingPage do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:page_title, :string)
    field(:target_audience, :string)
    embeds_many(:sections, LandingPageSection)
  end
end

defmodule Hello.Documents.LandingPage.Feedback do
  use Ecto.Schema
  use InstructorLite.Instruction

  @primary_key false
  embedded_schema do
    field(:feedback, {:array, :string})
    field(:needs_refinement, :boolean)
  end
end
