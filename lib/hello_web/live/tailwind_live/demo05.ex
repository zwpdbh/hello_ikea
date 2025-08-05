defmodule HelloWeb.TailwindLive.Demo05 do
  use HelloWeb, :live_view
  import HelloWeb.ResumeComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.resume>
      <.resume_sidebar>
        <.resume_sidebar_info
          name="Wei Zhao"
          email="hyperion_z@outlook.com"
          introduction=" Fullstack developer who use Elixir to find myself."
        >
        </.resume_sidebar_info>

        <.resume_sidebar_section>
          <.resume_sidebar_section_item
            title="Main Skill Stack"
            content="Elixir, Rust, JavaScript, Azure, AWS"
          >
          </.resume_sidebar_section_item>

          <.resume_sidebar_section_item title="Telephone" content="(+086)15811257483">
          </.resume_sidebar_section_item>
        </.resume_sidebar_section>
      </.resume_sidebar>

      <.resume_main_content>
        <.resume_general_section title="Current Status">
          <div>
            Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
          </div>
        </.resume_general_section>

        <.project_section>
          <.project_item title="Azure Container Storage Test" company="Microsoft" period="2021 - 2025">
            Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
          </.project_item>

          <.project_item title="Azure Container Storage Test" company="Microsoft" period="2021 - 2025">
            Chupa chups powder wafer marzipan gingerbread oat cake. Chocolate pudding carrot cake donut dragée dessert. Tootsie roll pie brownie donut candy ice cream tiramisu lemon drops. Halvah lollipop gummi bears liquorice fruitcake. Oat cake cheesecake liquorice powder
          </.project_item>
        </.project_section>

        <.education_section>
          <.education_item
            school="University of Otago"
            major="Computer Science, MASc"
            period="2016 - 2018"
          />
          <.education_item
            school="Beijing University of Technology"
            major="Computer Science, BS"
            period="2004 - 2009"
          />
        </.education_section>
      </.resume_main_content>
    </.resume>
    """
  end
end
