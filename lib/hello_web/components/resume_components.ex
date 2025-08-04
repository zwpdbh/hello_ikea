defmodule HelloWeb.ResumeComponents do
  use Phoenix.Component
  use Gettext, backend: HelloWeb.Gettext

  attr :title, :string, required: true
  attr :content, :string, required: true
  slot :inner_block, required: false

  def resume_sidebar_section_item(assigns) do
    ~H"""
    <div>
      <div class="font-sm">{@title}</div>
      <div class="font-bold">{@content}</div>
    </div>
    """
  end

  slot :inner_block, required: true

  def resume_sidebar_section(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="text-2xl font-bold">About</div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :name, :string, required: true
  attr :email, :string, required: true
  attr :introduction, :string, required: false
  slot :inner_block, required: false

  def resume_sidebar_info(assigns) do
    ~H"""
    <div>
      <div class="text-3xl font-bold">{@name}</div>
      <div class="mb-8">{@email}</div>
      <div>
        {@introduction}
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def resume_sidebar(assigns) do
    ~H"""
    <div class="divide-y divide-gray-300">
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :title, :string, required: true
  attr :company, :string, required: true
  attr :period, :string, required: true
  slot :inner_block, required: true

  def project_item(assigns) do
    ~H"""
    <div>
      <div class="transform -translate-x-4 flex items-center divide-x divide-gray-300 mb-2">
        <div class="font-semibold pr-3">{@title}</div>
        <div class="flex pl-3 space-x-3">
          <div class="text-sm font-medium italic">{@company}</div>
          <div class="text-sm font-light">{@period}</div>
        </div>
      </div>
      <div>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def project_section(assigns) do
    ~H"""
    <div class="container max-auto">
      <div class="relative bg-white p-7 shadow-lg rounded">
        <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
          Project Experimence
        </div>
        <div class="space-y-5">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  attr :school, :string, required: true
  attr :major, :string, required: true
  attr :period, :string, required: true
  slot :inner_block, required: false

  def education_item(assigns) do
    ~H"""
    <div class="flex items-center divide-x divide-gray-300">
      <div class="font-semibold pr-3">{@school}</div>
      <div class="flex pl-3 space-x-3">
        <div class="text-sm font-medium italic">{@major}</div>
        <div class="text-sm font-light">{@period}</div>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def education_section(assigns) do
    ~H"""
    <div class="container max-auto">
      <div class="relative bg-white p-7 shadow-lg rounded">
        <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
          Education
        </div>
        <div class="space-y-2">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  slot :inner_block, required: true

  def resume_general_section(assigns) do
    ~H"""
    <div class="container max-auto">
      <div class="relative bg-white p-7 shadow-lg rounded">
        <div class="absolute top-0 left-0 text-lg font-bold rounded px-4 py-1 transform -translate-x-2 -translate-y-2">
          {@title}
        </div>
        <div>
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def resume_main_content(assigns) do
    ~H"""
    <div class="col-start-2 col-span-5 space-y-2">
      {render_slot(@inner_block)}
    </div>
    """
  end

  slot :inner_block, required: true

  def resume(assigns) do
    ~H"""
    <div class="p-20 bg-white grid grid-cols-6 gap-4 text-gray-800">
      {render_slot(@inner_block)}
    </div>
    """
  end
end
